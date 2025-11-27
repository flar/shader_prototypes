// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:shader_prototypes/shader_prototypes.dart';

/// A utility class to manage the uniform fields of a `vec3` uniform in
/// a shader `.frag` file.
///
/// This class also subclasses the base Vec3 object providing read and write
/// access to the data. Though the data is not fetched from the shader and
/// instead is remembered by the base class which means the data can get out
/// of sync if multiple UniformVec3 objects are instantiated with the same
/// shader and base offset, or if the shader uniforms are set using other
/// means. If this class is used to manage shader uniform data, then no other
/// mechanisms should be used to modify that uniform data.
///
/// See also:
///
/// * [FragmentShader.setFloat] which can also update the uniform values in
///   the supplied [shader] object.
class UniformVec3 extends Vec3 {
  /// Instantiate a wrapper that will manipulate the vec3 fields on the
  /// indicated [FragmentShader] located at the indicated `base`.
  ///
  /// See also:
  ///
  /// * [FragmentShader.setFloat], used to update the uniform values in
  ///   the supplied [shader] object.
  UniformVec3(this.shader, this.base);

  /// Set the x sub-field of the associated vec3 uniform.
  @override
  set x(double x) {
    super.x = x;
    shader.setFloat(base + 0, x);
  }

  /// Set the y sub-field of the associated vec3 uniform.
  @override
  set y(double y) {
    super.y = y;
    shader.setFloat(base + 1, y);
  }

  /// Set the z sub-field of the associated vec3 uniform.
  @override
  set z(double z) {
    super.z = z;
    shader.setFloat(base + 2, z);
  }

  /// The [FragmentShader] instance in which the associated vec3 is a uniform.
  final FragmentShader shader;
  /// The integer index base of the associated vec3 uniform within the shader.
  final int base;
}
