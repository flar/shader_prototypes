// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

/// A 3 element vector class that mimics the field access behaviors of
/// a GPU vec3 variable.
///
/// Though there are only 3 fields, these fields can be accessed using
/// any of:
///
/// - x - the first element
/// - y - the second element
/// - z - the third element
///
/// - s - an alias for the first element
/// - t - an alias for the second element
/// - p - an alias for the third element
///
/// - xy - an alias for the first 2 elements together expressed as an Offset
/// - st - an alias for the first 2 elements together expressed as an Offset
///
/// - [] - indexing the elements as if they were a list:
/// - [0] - the x element
/// - [1] - the y element
/// - [2] - the z element
class Vec3 {
  /// Instantiate a Vec3 object with optional data, otherwise fields are
  /// initialized to 0s.
  Vec3([double v0 = 0.0, double v1 = 0.0, double v2 = 0.0])
      : x = v0, y = v1, z = v2;

  /// Set the x sub-field of the associated vec3 uniform.
  double x;
  /// Set the y sub-field of the associated vec3 uniform.
  double y;
  /// Set the z sub-field of the associated vec3 uniform.
  double z;

  /// Set the s sub-field of the associated vec3 uniform.
  set s(double s) => x = s;
  double get s => x;

  /// Set the t sub-field of the associated vec3 uniform.
  set t(double t) => y = t;
  double get t => y;

  /// Set the p sub-field of the associated vec3 uniform.
  set p(double p) => z = p;
  double get p => z;

  /// Set both the [x] and [y] sub-fields of the associated vec3 uniform.
  set xy(Offset o) { x = o.dx; y = o.dy; }
  Offset get xy => Offset(x, y);

  /// Set both the [s] and [t] sub-fields of the associated vec3 uniform.
  set st(Offset o) => xy = o;
  Offset get st => xy;

  /// Set a sub-field of the associated vec3 uniform by index.
  /// * index 0 sets the [x] or [s] sub-field.
  /// * index 1 sets the [y] or [t] sub-field.
  /// * index 2 sets the [z] or [p] sub-field.
  void operator []=(int index, double v) {
    switch (index) {
      case 0:
        x = v;
        break;
      case 1:
        y = v;
        break;
      case 2:
        z = v;
        break;
      default:
        throw RangeError('$index out of range');
    }
  }

  /// Get a sub-field of the associated vec3 uniform by index.
  /// * index 0 gets the [x] or [s] sub-field.
  /// * index 1 gets the [y] or [t] sub-field.
  /// * index 2 gets the [z] or [p] sub-field.
  double operator[](int index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return z;
      default:
        throw RangeError('$index out of range');
    }
  }
}
