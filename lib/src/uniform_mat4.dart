// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:shader_prototypes/shader_prototypes.dart';

/// A utility class to manage the uniform fields of a `mat4` uniform in
/// a shader `.frag` file.
///
/// This class also subclasses the base Mat4 object providing read and write
/// access to the data. Though the data is not fetched from the shader and
/// instead is remembered by the base class which means the data can get out
/// of sync if multiple Mat4 objects are instantiated with the same shader
/// and base offset, or if the shader uniforms are set using other means.
/// If this class is used to manage shader uniform data, then no other
/// mechanisms should be used to modify that uniform data.
///
/// See also:
///
/// * [FragmentShader.setFloat] which can also update the uniform values in
///   the supplied [shader] object.
class UniformMat4 extends Mat4 {
  /// Instantiate a wrapper that will provide column-by-column access to
  /// the mat4 using indexing to provide per-column [UniformVec4] objects,
  /// which also then provide a 2D matrix indexing through the indexing
  /// accessors of the [UniformVec4] class.
  ///
  /// ```dart
  ///    UniformMat4 mat
  ///    // These 2 lines do the same thing.
  ///    mat[0].x = 2.0;   // Sets the x value of the first column
  ///    mat[0][0] = 2.0;  // Sets the upper left corner of the matrix
  /// ```
  ///
  /// See also:
  ///
  /// * [FragmentShader.setFloat], used to update the uniform values in
  ///   the supplied [shader] object.
  UniformMat4(this.shader, this.base)
  : super.using(
      UniformVec4(shader, base + 0),
      UniformVec4(shader, base + 4),
      UniformVec4(shader, base + 8),
      UniformVec4(shader, base + 12));

  /// The [FragmentShader] instance in which the associated mat4 is a uniform.
  final FragmentShader shader;
  /// The integer index base of the associated mat4 uniform within the shader.
  final int base;
}
