import 'dart:ui';

class UniformVec2 {
  UniformVec2(this.shader, this.base);

  set x(double x) => shader.setFloat(base + 0, x);
  set y(double y) => shader.setFloat(base + 1, y);

  set s(double s) => x = s;
  set t(double t) => y = t;

  set xy(Offset o) { x = o.dx; y = o.dy; }
  set st(Offset o) => xy = o;

  void operator []=(int index, double v) {
    switch (index) {
      case 0:
        x = v;
        break;
      case 1:
        y = v;
        break;
      default:
        throw RangeError('vec2 only has 2 coordinates');
    }
  }

  final FragmentShader shader;
  final int base;
}