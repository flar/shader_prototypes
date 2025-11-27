// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

/// A 4 element vector class that mimics the field access behaviors of
/// a GPU vec4 variable.
///
/// Though there are only 4 fields, these fields can be accessed using
/// any of:
///
/// - x - the first element
/// - y - the second element
/// - z - the third element
/// - w - the fourth element
///
/// - s - an alias for the first element
/// - t - an alias for the second element
/// - p - an alias for the third element
/// - q - an alias for the fourth element
///
/// - xy - an alias for the first 2 elements together expressed as an Offset
/// - zw - an alias for the last 2 elements together expressed as an Offset
/// - st - an alias for the first 2 elements together expressed as an Offset
/// - pz - an alias for the last 2 elements together expressed as an Offset
///
/// - [] - indexing the elements as if they were a list:
/// - [0] - the x element
/// - [1] - the y element
/// - [2] - the z element
/// - [3] - the w element
class Vec4 {
  /// Instantiate a Vec3 object with optional data, otherwise fields are
  /// initialized to 0s.
  Vec4([double v0 = 0.0, double v1 = 0.0, double v2 = 0.0, double v3 = 0.0])
      : x = v0, y = v1, z = v2, w = v3;

  /// Set the x sub-field of the associated vec4 uniform.
  double x;
  /// Set the y sub-field of the associated vec4 uniform.
  double y;
  /// Set the z sub-field of the associated vec4 uniform.
  double z;
  /// Set the w sub-field of the associated vec4 uniform.
  double w;

  /// Set the s sub-field of the associated vec4 uniform.
  set s(double s) => x = s;
  double get s => x;
  /// Set the t sub-field of the associated vec4 uniform.
  set t(double t) => y = t;
  double get t => y;
  /// Set the p sub-field of the associated vec4 uniform.
  set p(double p) => z = p;
  double get p => z;
  /// Set the q sub-field of the associated vec4 uniform.
  set q(double q) => w = q;
  double get q => w;

  /// Set the r sub-field of the associated vec4 uniform.
  set r(double r) => x = r;
  double get r => x;
  /// Set the g sub-field of the associated vec4 uniform.
  set g(double g) => y = g;
  double get g => y;
  /// Set the b sub-field of the associated vec4 uniform.
  set b(double b) => z = b;
  double get b => z;
  /// Set the a sub-field of the associated vec4 uniform.
  set a(double a) => w = a;
  double get a => w;

  /// Set both the [x] and [y] sub-fields of the associated vec4 uniform.
  set xy(Offset o) { x = o.dx; y = o.dy; }
  Offset get xy => Offset(x, y);
  /// Set both the [z] and [w] sub-fields of the associated vec4 uniform.
  set zw(Offset o) { z = o.dx; w = o.dy; }
  Offset get zw => Offset(z, w);
  /// Set both the [s] and [t] sub-fields of the associated vec4 uniform.
  set st(Offset o) => xy = o;
  Offset get st => xy;
  /// Set both the [p] and [q] sub-fields of the associated vec4 uniform.
  set pq(Offset o) => zw = o;
  Offset get pq => zw;

  /// Set all 4 [r], [g], [b], and [a] sub-fields of the associated vec4
  /// uniform to the associated properties of the [Color] object.
  set color(Color c) {
    r = c.r;
    g = c.g;
    b = c.b;
    a = c.a;
  }
  Color get color => Color.from(alpha: a, red: r, green: g, blue: b);

  /// Set a sub-field of the associated vec4 uniform by index.
  /// * index 0 sets the [x] or [s] or [r] sub-field.
  /// * index 1 sets the [y] or [t] or [g] sub-field.
  /// * index 2 sets the [z] or [p] or [b] sub-field.
  /// * index 3 sets the [w] or [q] or [a] sub-field.
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
      case 3:
        w = v;
        break;
      default:
        throw RangeError('$index out of range');
    }
  }

  /// Get a sub-field of the associated vec4 uniform by index.
  /// * index 0 gets the [x] or [s] or [r] sub-field.
  /// * index 1 gets the [y] or [t] or [g] sub-field.
  /// * index 2 gets the [z] or [p] or [b] sub-field.
  /// * index 3 gets the [w] or [q] or [a] sub-field.
  double operator[](int index) {
    switch (index) {
      case 0:
        return x;
      case 1:
        return y;
      case 2:
        return z;
      case 3:
        return w;
      default:
        throw RangeError('$index out of range');
    }
  }
}
