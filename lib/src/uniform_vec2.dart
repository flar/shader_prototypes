// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:shader_prototypes/src/vec2.dart';

/// A utility class to manage the uniform fields of a `vec2` uniform in
/// a shader `.frag` file.
///
/// This class also subclasses the base Vec2 object providing read and write
/// access to the data. Though the data is not fetched from the shader and
/// instead is remembered by the base class which means the data can get out
/// of sync if multiple UniformVec2 objects are instantiated with the same
/// shader and base offset, or if the shader uniforms are set using other
/// means. If this class is used to manage shader uniform data, then no other
/// mechanisms should be used to modify that uniform data.
///
/// See also:
///
/// * [FragmentShader.setFloat] which can also update the uniform values in
///   the supplied [shader] object.
class UniformVec2 extends Vec2 {
  /// Instantiate a wrapper that will manipulate the vec2 fields on the
  /// indicated [FragmentShader] located at the indicated `base`.
  ///
  /// See also:
  ///
  /// * [FragmentShader.setFloat], used to update the uniform values in
  ///   the supplied [shader] object.
  UniformVec2(this.shader, this.base);

  /// Set the x sub-field of the associated vec2 uniform both in the
  /// base class and in the float uniforms of the associated shader.
  @override
  set x(double x) {
    super.x = x;
    shader.setFloat(base + 0, x);
  }

  /// Set the y sub-field of the associated vec2 uniform both in the
  /// base class and in the float uniforms of the associated shader.
  @override
  set y(double y) {
    super.y = y;
    shader.setFloat(base + 1, y);
  }

  /// The [FragmentShader] instance in which the associated vec2 is a uniform.
  final FragmentShader shader;
  /// The integer index base of the associated vec2 uniform within the shader.
  final int base;
}
