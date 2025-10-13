// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

/// A utility class to manage the uniform fields of a `vec4` uniform in
/// a shader `.frag` file.
///
/// This class provides shader language style access to the vec4 using
/// a subset of the field naming conventions and aliases available in
/// shader languages like glsl such as `xyzw` and `stpq`.
class UniformVec4 {
  /// Instantiate a wrapper that will manipulate the vec4 fields on the
  /// indicated FragmentShader located at the indicated `base`.
  ///
  /// See also:
  ///
  /// * [FragmentShader.setFloat], used to update the uniform values in
  ///   the supplied [shader] object.
  UniformVec4(this.shader, this.base);

  /// Set the x sub-field of the associated vec4 uniform.
  set x(double x) => shader.setFloat(base + 0, x);
  /// Set the y sub-field of the associated vec4 uniform.
  set y(double y) => shader.setFloat(base + 1, y);
  /// Set the z sub-field of the associated vec4 uniform.
  set z(double z) => shader.setFloat(base + 2, z);
  /// Set the w sub-field of the associated vec4 uniform.
  set w(double w) => shader.setFloat(base + 3, w);

  /// Set the s sub-field of the associated vec4 uniform.
  set s(double s) => x = s;
  /// Set the t sub-field of the associated vec4 uniform.
  set t(double t) => y = t;
  /// Set the p sub-field of the associated vec4 uniform.
  set p(double p) => z = p;
  /// Set the q sub-field of the associated vec4 uniform.
  set q(double q) => w = q;

  /// Set the r sub-field of the associated vec4 uniform.
  set r(double r) => x = r;
  /// Set the g sub-field of the associated vec4 uniform.
  set g(double g) => y = g;
  /// Set the b sub-field of the associated vec4 uniform.
  set b(double b) => z = b;
  /// Set the a sub-field of the associated vec4 uniform.
  set a(double a) => w = a;

  /// Set both the [x] and [y] sub-fields of the associated vec4 uniform.
  set xy(Offset o) { x = o.dx; y = o.dy; }
  /// Set both the [z] and [w] sub-fields of the associated vec4 uniform.
  set zw(Offset o) { z = o.dx; w = o.dy; }
  /// Set both the [s] and [t] sub-fields of the associated vec4 uniform.
  set st(Offset o) => xy = o;
  /// Set both the [p] and [q] sub-fields of the associated vec4 uniform.
  set pq(Offset o) => zw = o;

  /// Set all 4 [r], [g], [b], and [a] sub-fields of the associated vec4
  /// uniform to the associated properties of the [Color] object.
  set color(Color c) {
    r = c.r;
    g = c.g;
    b = c.b;
    a = c.a;
  }

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

  /// The [FragmentShader] instance in which the associated vec4 is a uniform.
  final FragmentShader shader;
  /// The integer index base of the associated vec4 uniform within the shader.
  final int base;
}
