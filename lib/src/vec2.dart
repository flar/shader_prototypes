// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

/// A 2 element vector class that mimics the field access behaviors of
/// a GPU vec2 variable.
///
/// Though there are only 2 fields, these fields can be accessed using
/// any of:
///
/// - x - the first element
/// - y - the second element
///
/// - s - an alias for the first element
/// - t - an alias for the second element
///
/// - xy - an alias for the 2 elements together expressed as an Offset
/// - st - an alias for the 2 elements together expressed as an Offset
///
/// - [] - indexing the elements as if they were a list:
/// - [0] - the x element
/// - [1] - the y element
/// - [2] - the z element
class Vec2 {
  /// Instantiate a Vec2 object with optional data, otherwise fields are
  /// initialized to 0s.
  Vec2([double v0 = 0.0, double v1 = 0.0])
    : x = v0, y = v1;

  double x;
  double y;

  /// Set the s sub-field of the associated vec2 uniform (aliased to [x]).
  set s(double s) => x = s;
  double get s => x;

  /// Set the t sub-field of the associated vec2 uniform (aliased to [y]).
  set t(double t) => y = t;
  double get t => y;

  /// Set both the [x] and [y] sub-fields of the associated vec2 uniform.
  set xy(Offset o) { x = o.dx; y = o.dy; }
  Offset get xy => Offset(x, y);

  /// Set both the [s] and [t] sub-fields of the associated vec2 uniform.
  set st(Offset o) => xy = o;
  Offset get st => xy;

  /// Set a sub-field of the associated vec2 uniform by index.
  /// * index 0 sets the [x] or [s] sub-field.
  /// * index 1 sets the [y] or [t] sub-field.
  void operator []=(int index, double v) {
    switch (index) {
      case 0:
        x = v;
        break;
      case 1:
        y = v;
        break;
      default:
        throw RangeError('$index out of range');
    }
  }

  /// Get a sub-field of the associated vec2 uniform by index.
  /// * index 0 gets the [x] or [s] sub-field.
  /// * index 1 gets the [y] or [t] sub-field.
  double operator[](int index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      default:
        throw RangeError('$index out of range');
    }
  }
}
