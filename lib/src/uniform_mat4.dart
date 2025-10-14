// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:shader_prototypes/src/uniform_vec4.dart';

/// A utility class to manage the uniform fields of a `mat4` uniform in
/// a shader `.frag` file.
///
/// This class provides shader language style access to the mat4 using
/// the column based indexing of the structure as if it were either
/// a 4x4 matrix, or a list of 4 vec4 fields.
class UniformMat4 {
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
  UniformMat4(this.shader, this.base) {
    _columns = <UniformVec4>[
      UniformVec4(shader, base + 0),
      UniformVec4(shader, base + 4),
      UniformVec4(shader, base + 8),
      UniformVec4(shader, base + 12),
    ];
  }

  /// Get the [UniformVec4] view of the indexed column of the mat4.
  UniformVec4 operator [](int index) => _columns[index];

  /// Set the entire matrix from the matrix storage of the given [Matrix4].
  set matrix(Matrix4 matrix) => list64 = matrix.storage;
  /// Set the entire matrix from the column major Float list.
  set list64(Float64List storage) {
    for (int i = 0; i < 16; i++) {
      shader.setFloat(base + i, storage[i]);
    }
  }


  /// The [FragmentShader] instance in which the associated mat4 is a uniform.
  final FragmentShader shader;
  /// The integer index base of the associated mat4 uniform within the shader.
  final int base;

  // The private internal list of the 4 [UniformVec4] instances for the 4
  // columns of the matrix.
  late final List<UniformVec4> _columns;
}
