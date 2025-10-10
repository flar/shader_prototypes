import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:shader_prototypes/src/uniform_vec4.dart';

class UniformMat4 {
  UniformMat4(this.shader, this.base) {
    _columns = <UniformVec4>[
      UniformVec4(shader, base + 0),
      UniformVec4(shader, base + 1),
      UniformVec4(shader, base + 2),
      UniformVec4(shader, base + 3),
    ];
  }

  UniformVec4 operator [](int index) => _columns[index];

  set matrix(Matrix4 matrix) => list64 = matrix.storage;
  set list64(Float64List storage) {
    for (int i = 0; i < 16; i++) {
      shader.setFloat(base + i, storage[i]);
    }
  }

  final FragmentShader shader;
  final int base;

  late final List<UniformVec4> _columns;
}