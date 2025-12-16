// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

late ArgResults argResults;
Logger _logger = Logger('GeneratePrototypes');

String getArtifactsPath() {
  String path = Platform.environment['PATH'] ?? 'PATH=';
  List<String> pathDirs = path.replaceAll('PATH=', '').split(':');
  for (String dir in pathDirs) {
    if (dir.endsWith('bin/cache/dart-sdk/bin')) {
      Directory binDir = Directory(dir.replaceAll('cache/dart-sdk/bin', ''));
      if (!binDir.existsSync()) {
        continue;
      }
      for (var child in binDir.listSync(recursive: true)) {
        if (child is File) {
          if (child.uri.pathSegments.last == 'impellerc') {
            return child.parent.path;
          }
        }
      }
    }
  }
  throw 'impellerc not found';
}

dynamic getYaml(YamlMap doc, String spec) {
  List<String> specList = spec.split(':');
  for (int i = 0; i < specList.length - 1; i++) {
    dynamic part = doc[specList[i]];
    if (part is YamlMap) {
      doc = part;
    } else {
      return null;
    }
  }
  return doc[specList.last];
}

String? getYamlString(YamlMap doc, String spec) {
  return getYaml(doc, spec);
}

bool? getYamlBool(YamlMap doc, String spec) {
  return getYaml(doc, spec);
}

String getOutputDir(YamlMap doc) {
  String outputDirArg = argResults.option('output-dir')
      ?? getYamlString(doc, 'shader_prototypes:output')
      ?? 'lib/gen/shader-prototypes';
  if (!outputDirArg.endsWith('/')) {
    outputDirArg += '/';
  }
  return outputDirArg;
}

String artifactsPath = getArtifactsPath();
late String outputDir;
late bool updateGitIgnore;

void main(List<String> args) async {
  ArgParser parser = ArgParser();
  parser.addOption(
    'output-dir',
    help: 'Directory to write the shader class source files.'
  );
  parser.addFlag(
    'force',
    abbr: 'f',
    defaultsTo: false,
    help: 'Rewrite shader prototype files without checking previous contents',
  );
  parser.addFlag(
    'verbose',
    abbr: 'v',
    defaultsTo: false,
    help: 'Verbose output from logging',
  );
  parser.addFlag('help', abbr: 'h');
  argResults = parser.parse(args);

  if (argResults.flag('help')) {
    sinkAllLines(stdout, <String>[
      'A utility to generate Dart language class definitions from'
          ' fragment shader source files.',
      '',
      'Usage: dart run shader_prototypes:generate_prototypes [arguments]',
      '',
      'Global options:',
      parser.usage,
    ]);
    return;
  }

  hierarchicalLoggingEnabled = true;
  _logger.level = argResults.flag('verbose') ? Level.ALL : Level.WARNING;
  _logger.onRecord.listen((record) {
    stdout.writeln('${record.level.name}: ${record.time}: ${record.message}');
  });

  final File pubspecFile = File('pubspec.yaml');
  final String yamlString = pubspecFile.readAsStringSync();
  final YamlMap doc = loadYaml(yamlString);

  outputDir = getOutputDir(doc);
  updateGitIgnore = getYamlBool(doc, 'shader_prototypes:update-gitignore') ?? false;

  YamlList shaders = doc['flutter']['shaders'];
  for (var shader in shaders) {
    generatePrototype(shader);
  }
}

enum UniformType {
  float,
  vec2,
  vec3,
  vec4,
  mat4,
  sampler,
}

class Uniform implements Comparable<Uniform> {
  Uniform({required this.type, required this.name, required this.location});

  final UniformType type;
  final String name;
  // The location taken from the json file which indicates either the location
  // that the developer declared in their .frag file, or the order in which
  // the uniform was declared.
  final int location;
  // The computed base index of the data for this uniform once all of the
  // uniforms are read and sorted by location.
  int? base;

  @override
  String toString() => 'Uniform($type, $name)';

  @override
  int compareTo(Uniform other) {
    if (type == .sampler) {
      if (other.type != .sampler) {
        return -1;
      }
    } else if (other.type == .sampler) {
      return 1;
    }
    return location.compareTo(other.location);
  }
}

void generatePrototype(String shaderPath) {
  File shaderFile = File(shaderPath);
  if (!shaderFile.existsSync()) {
    _logger.severe("Shader file '$shaderPath' does not exist");
    return;
  }

  List<Uniform>? uniforms;
  try {
    uniforms = extractUniformsImpellerc(shaderFile);
  } catch (_) {
    uniforms = null;
  }
  if (uniforms == null) {
    _logger.warning('Unable to extract uniforms from ${shaderFile.path} using impellerc');
    _logger.warning('Using less reliable text parsing of the shader file to find uniforms instead');
    uniforms = extractUniformsText(shaderFile);
  }
  if (uniforms.isEmpty) {
    _logger.info('No uniforms found in $shaderPath');
    return;
  }
  sortAndIndexUniforms(uniforms);

  List<String> headerLines = <String>[
    '// GENERATED CODE - DO NOT MODIFY BY HAND',
    '// THIS FILE IS GENERATED BY generate_prototypes.dart FROM $shaderPath.',
    '',
  ];
  List<String> protoFileLines = generatePrototypeFile(shaderPath, uniforms, headerLines);

  String protoPath = shaderPath
      .replaceFirst(RegExp(r'.frag$'), '.dart')
      .replaceFirst(RegExp('^shaders/'), '');
  File protoFile = File('$outputDir/$protoPath');

  if (!argResults['force'] && protoFile.existsSync()) {
    // Check if we can write to it...
    int common = linesInCommon(protoFile, protoFileLines);
    if (common == protoFileLines.length) {
      _logger.info('Prototype $protoPath does not need updating');
      return;
    }
    if (common < headerLines.length) {
      throw 'incompatible prototype file exists in $protoPath';
    }
  }

  protoFile.createSync(recursive: true);
  var sink = protoFile.openWrite();
  sinkAllLines(sink, protoFileLines);
  addToGitIgnore(protoPath);
}

void addToGitIgnore(String path) {
  if (!updateGitIgnore) {
    return;
  }
  File ignoreFile = File('$outputDir/.gitignore');
  if (ignoreFile.existsSync()) {
    List<String> existingIgnores = ignoreFile.readAsLinesSync();
    for (var ignore in existingIgnores) {
      if (ignore == path) {
        return;
      }
    }
    String contents = ignoreFile.readAsStringSync();
    if (contents.isNotEmpty && !contents.endsWith('\n')) {
      path = '\n$path';
    }
  }
  ignoreFile.writeAsStringSync('$path\n', mode: FileMode.append);
}

List<Uniform>? extractUniformsImpellerc(File shaderFile) {
  Directory temp = Directory(Directory.systemTemp.path).createTempSync('shader_proto');
  String impellercPath = '$artifactsPath/impellerc';
  ProcessResult result = Process.runSync(impellercPath, [
    '--include=$artifactsPath/shader_lib',
    '--input-type=frag',
    '--iplr',
    '--json',
    '--runtime-stage-metal',
    '--input=${shaderFile.path}',
    '--spirv=${temp.path}/shader.spirv',
    '--reflection-json=${temp.path}/shader.json',
    '--sl=${temp.path}/shader.sl',
  ]);
  for (var line in LineSplitter.split(result.stdout)) {
    _logger.fine('[IMPELLERC][STDOUT] $line');
  }
  for (var line in LineSplitter.split(result.stderr)) {
    _logger.fine('[IMPELLERC][STDERR] $line');
  }
  if (result.exitCode != 0) {
    _logger.severe('impellerc failed to compile shader ${shaderFile.path} (exit code ${result.exitCode})');
  } else {
    for (var line in File('${temp.path}/shader.json').readAsLinesSync()) {
      _logger.info('[JSON]: $line');
    }
    var json = jsonDecode(File('${temp.path}/shader.json').readAsStringSync());
    if (json == null) {
      _logger.severe('impellerc failed to produce a json file from ${shaderFile.path}');
    } else if (!json["sampled_images"] || !json["uniforms"]) {
      _logger.info('impellerc failed to reflect uniform entries from ${shaderFile.path}');
    } else {
      List<Uniform> uniformsList = <Uniform>[];
      parseUniforms(json['sampled_images'], uniformsList, shaderFile.path);
      parseUniforms(json['uniforms'], uniformsList, shaderFile.path);
      return uniformsList;
    }
  }
  return null;
}

void parseUniforms(dynamic uniformsJsonList, List<Uniform> uniformsList, String shaderPath) {
  if (uniformsJsonList == null) {
    _logger.severe('impellerc did not find uniforms in $shaderPath');
  } else {
    for (var uniformMap in uniformsJsonList) {
      Uniform? uniform = parse(uniformMap, shaderPath);
      if (uniform != null) {
        uniformsList.add(uniform);
      } else {
        _logger.severe('No uniform from $uniformMap');
      }
    }
  }
}

Uniform? parse(dynamic uniformMap, String shaderPath) {
  int? location = uniformMap['location'];
  String? name = uniformMap['name'];
  UniformType? type;
  dynamic typeMap = uniformMap['type'];
  if (typeMap != null) {
    switch (typeMap['type_name']) {
      case 'ShaderType::kSampledImage':
        type = UniformType.sampler;
        break;
      case 'ShaderType::kFloat': {
        int? columns = typeMap['columns'];
        int? vecSize = typeMap['vec_size'];
        if (columns == 4) {
          if (vecSize == 4) {
            type = UniformType.mat4;
          }
        } else if (columns == 1) {
          type = switch(vecSize) {
            1 => UniformType.float,
            2 => UniformType.vec2,
            3 => UniformType.vec3,
            4 => UniformType.vec4,
            _ => null,
          };
        }
      }
    }
  }
  if (name == null || location == null || type == null) {
    _logger.severe('Malformed uniform: $uniformMap in $shaderPath');
    return null;
  }
  return Uniform(name: name, location: location, type: type);
}

List<Uniform> extractUniformsText(File shaderFile) {
  List<Uniform> uniforms = [];
  List<String> lines = shaderFile.readAsLinesSync();
  int lineNumber = 0;
  int uniformLocation = 0;
  for (var line in lines) {
    lineNumber++;
    line = line.replaceFirst(RegExp(r'//.*$'), '');
    line = line.trim();
    List<String> words = line.split(RegExp(r' +'));
    if (!words.contains('uniform')) {
      continue;
    }
    if (!words.last.endsWith(';')) {
      continue;
    }
    String name = words.last.substring(0, words.last.length - 1);
    if (name.isEmpty) {
      continue;
    }
    int uniformCount = uniforms.length;
    for (String word in words) {
      switch (word) {
        case 'float':
          uniforms.add(
              Uniform(type: UniformType.float, name: name, location: uniformLocation++));
          break;
        case 'vec2':
          uniforms.add(
              Uniform(type: UniformType.vec2, name: name, location: uniformLocation++));
          break;
        case 'vec3':
          uniforms.add(
              Uniform(type: UniformType.vec3, name: name, location: uniformLocation++));
          break;
        case 'vec4':
          uniforms.add(
              Uniform(type: UniformType.vec4, name: name, location: uniformLocation++));
          break;
        case 'mat4':
          uniforms.add(
              Uniform(type: UniformType.mat4, name: name, location: uniformLocation++));
          break;
        case 'sampler2D':
          uniforms.add(Uniform(
              type: UniformType.sampler, name: name, location: uniformLocation++));
          break;
        default:
          continue;
      }
      break;
    }
    if (uniformCount == uniforms.length) {
      _logger.severe('Unrecognized uniform declaration at line $lineNumber: $line');
    }
  }
  return uniforms;
}

void sortAndIndexUniforms(List<Uniform> uniforms) {
  uniforms.sort();
  int samplerBase = 0;
  int floatBase = 0;
  for (Uniform uniform in uniforms) {
    switch (uniform.type) {
      case .sampler:
        uniform.base = samplerBase;
        samplerBase++;
        break;
      case .float:
        uniform.base = floatBase;
        floatBase++;
        break;
      case .vec2:
        uniform.base = floatBase;
        floatBase += 2;
        break;
      case .vec3:
        uniform.base = floatBase;
        floatBase += 3;
        break;
      case .vec4:
        uniform.base = floatBase;
        floatBase += 4;
        break;
      case .mat4:
        uniform.base = floatBase;
        floatBase += 16;
        break;
    }
  }
}
List<String> generatePrototypeFile(String shaderPath, List<Uniform> uniforms, List<String> headerLines) {
  uniforms.sort();
  String shaderClassName = shaderPath
      .replaceAll(RegExp(r'.*/'), '')
      .replaceAll('.frag', '')
      .replaceAllMapped(RegExp(r'_([a-zA-Z])'), (Match m) => m[1]!.toUpperCase())
      .replaceAllMapped(RegExp(r'^([a-zA-Z])'), (Match m) => m[1]!.toUpperCase());
  List<String> accessLines = <String>[];
  for (var uniform in uniforms) {
    switch (uniform.type) {
      case UniformType.vec2:
        accessLines.add('  late final Vec2 ${uniform.name} = UniformVec2(shader, ${uniform.base});');
        accessLines.add('');
        break;
      case UniformType.vec3:
        accessLines.add('  late final Vec3 ${uniform.name} = UniformVec3(shader, ${uniform.base});');
        accessLines.add('');
        break;
      case UniformType.vec4:
        accessLines.add('  late final Vec4 ${uniform.name} = UniformVec4(shader, ${uniform.base});');
        accessLines.add('');
        break;
      case UniformType.mat4:
        accessLines.add('  late final Mat4 ${uniform.name} = UniformMat4(shader, ${uniform.base});');
        accessLines.add('');
        break;
      case UniformType.float:
        accessLines.add('  double _${uniform.name} = 0.0;');
        accessLines.add('  set ${uniform.name}(double value) {');
        accessLines.add('    _${uniform.name} = value;');
        accessLines.add('    shader.setFloat(${uniform.base}, value);');
        accessLines.add('  }');
        accessLines.add('  double get ${uniform.name} => _${uniform.name};');
        accessLines.add('');
        break;
      case UniformType.sampler:
        accessLines.add('  Image? _${uniform.name};');
        accessLines.add('  set ${uniform.name}(Image image) {');
        accessLines.add('    _${uniform.name} = image;');
        accessLines.add('    shader.setImageSampler(${uniform.base}, image);');
        accessLines.add('  }');
        accessLines.add('  Image? get ${uniform.name} => _${uniform.name};');
        accessLines.add('');
        break;
    }
  }

  return <String>[
    ...headerLines,
    "import 'dart:ui';",
    '',
    "import 'package:shader_prototypes/shader_prototypes.dart';",
    '',
    'class $shaderClassName {',
    '  $shaderClassName() : shader = _program!.fragmentShader();',
    '',
    '  final FragmentShader shader;',
    '',
    ...accessLines,
    '  static FragmentProgram? _program;',
    '  static Future<void> init() async {',
    "    _program = await FragmentProgram.fromAsset('$shaderPath');",
    '  }',
    '}',
  ];
}

int linesInCommon(File protoFile, List<String> newPrototypeLines) {
  List<String> existingLines = protoFile.readAsLinesSync();
  int commonLineCount = min(existingLines.length, newPrototypeLines.length);
  for (int i = 0; i < commonLineCount; i++) {
    if (existingLines[i] != newPrototypeLines[i]) {
      _logger.warning("header line ${i + 1} in ${protoFile.path} doesn't match expected: "
          "${existingLines[i]} != ${newPrototypeLines[i]}");
      return i;
    }
  }
  return commonLineCount;
}

void sinkAllLines(IOSink sink, List<String> lines) {
  for (String line in lines) {
    sink.writeln(line);
  }
  sink.flush();
}
