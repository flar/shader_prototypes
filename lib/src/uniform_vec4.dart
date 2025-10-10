import 'dart:ui';

class UniformVec4 {
  UniformVec4(this.shader, this.base);

  set x(double x) => shader.setFloat(base + 0, x);
  set y(double y) => shader.setFloat(base + 1, y);
  set z(double z) => shader.setFloat(base + 2, z);
  set w(double w) => shader.setFloat(base + 3, w);

  set s(double s) => x = s;
  set t(double t) => y = t;
  set p(double p) => z = p;
  set q(double q) => w = q;

  set r(double r) => x = r;
  set g(double g) => y = g;
  set b(double b) => z = b;
  set a(double a) => w = a;

  set xy(Offset o) { x = o.dx; y = o.dy; }
  set zw(Offset o) { z = o.dx; w = o.dy; }
  set st(Offset o) => xy = o;
  set pq(Offset o) => zw = o;

  set color(Color c) {
    r = c.r;
    g = c.g;
    b = c.b;
    a = c.a;
  }

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

  final FragmentShader shader;
  final int base;
}