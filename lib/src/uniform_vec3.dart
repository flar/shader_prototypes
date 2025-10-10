import 'dart:ui';

class UniformVec3 {
  UniformVec3(this.shader, this.base);

  set x(double x) => shader.setFloat(base + 0, x);
  set y(double y) => shader.setFloat(base + 1, y);
  set z(double z) => shader.setFloat(base + 2, z);

  set s(double s) => x = s;
  set t(double t) => y = t;
  set p(double p) => z = p;

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
      case 2:
        z = v;
        break;
      default:
        throw RangeError('$index out of range');
    }
  }

  final FragmentShader shader;
  final int base;
}