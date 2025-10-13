// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

/// A utility class to manage the uniform fields of a `vec3` uniform in
/// a shader `.frag` file.
///
/// This class provides shader language style access to the vec3 using
/// a subset of the field naming conventions and aliases available in
/// shader languages like glsl such as `xyz` and `stp`.
class UniformVec3 {
  /// Instantiate a wrapper that will manipulate the vec3 fields on the
  /// indicated [FragmentShader] located at the indicated `base`.
  ///
  /// See also:
  ///
  /// * [FragmentShader.setFloat], used to update the uniform values in
  ///   the supplied [shader] object.
  UniformVec3(this.shader, this.base);

  /// Set the x sub-field of the associated vec3 uniform.
  set x(double x) => shader.setFloat(base + 0, x);
  /// Set the y sub-field of the associated vec3 uniform.
  set y(double y) => shader.setFloat(base + 1, y);
  /// Set the z sub-field of the associated vec3 uniform.
  set z(double z) => shader.setFloat(base + 2, z);

  /// Set the s sub-field of the associated vec3 uniform.
  set s(double s) => x = s;
  /// Set the t sub-field of the associated vec3 uniform.
  set t(double t) => y = t;
  /// Set the p sub-field of the associated vec3 uniform.
  set p(double p) => z = p;

  /// Set both the [x] and [y] sub-fields of the associated vec3 uniform.
  set xy(Offset o) { x = o.dx; y = o.dy; }
  /// Set both the [s] and [t] sub-fields of the associated vec3 uniform.
  set st(Offset o) => xy = o;

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

  /// The [FragmentShader] instance in which the associated vec3 is a uniform.
  final FragmentShader shader;
  /// The integer index base of the associated vec3 uniform within the shader.
  final int base;
}
