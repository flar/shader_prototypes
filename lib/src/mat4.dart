// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:shader_prototypes/shader_prototypes.dart';

/// A 4x4 element matrix class that mimics the field access behaviors of
/// a GPU mat4 variable.
///
/// This class provides shader language style access to the mat4 using
/// the column based indexing of the structure as if it were either
/// a 4x4 matrix, or a list of 4 vec4 fields, as in:
///
/// ```dart
///    UniformMat4 mat
///    // These 2 lines do the same thing.
///    mat[0].x = 2.0;   // Sets the x value of the first column
///    mat[0][0] = 2.0;  // Sets the upper left corner of the matrix
/// ```
class Mat4 {
  /// Instantiate a Mat4 class with all matrix elements initialized to
  /// zeros.
  Mat4() : _columns = <Vec4>[Vec4(), Vec4(), Vec4(), Vec4()];

  /// Instantiate a Mat4 class with the indicated Vec4 objects as the
  /// columns. Note that no effort is made to distinguish whether these
  /// Vec4 objects are unique, but providing duplicates between the
  /// columns would cause chaos in using this object as a 4x4 matrix.
  Mat4.using(Vec4 c0, Vec4 c1, Vec4 c2, Vec4 c3)
      : _columns = <Vec4>[c0, c1, c2, c3];

  /// Get the [UniformVec4] view of the indexed column of the mat4.
  Vec4 operator [](int index) => _columns[index];

  /// Set the entire matrix from the matrix storage of the given [Matrix4].
  set matrix(Matrix4 matrix) => list64 = matrix.storage;
  /// Set the entire matrix from the column major Float list.
  set list64(Float64List storage) {
    for (int c = 0; c < 4; c++) {
      Vec4 vec = _columns[c];
      for (int r = 0; r < 4; r++) {
        vec[r] = storage[c * 4 + r];
      }
    }
  }

  // The private internal list of the 4 [UniformVec4] instances for the 4
  // columns of the matrix.
  final List<Vec4> _columns;
}
