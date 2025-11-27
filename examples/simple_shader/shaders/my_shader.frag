#include <flutter/runtime_effect.glsl>

uniform vec4 uColor;
uniform float uScale;

out vec4 fragColor;

void main() {
  vec2 pos = FlutterFragCoord();

  fragColor = vec4(
    mod(uColor.r - pos.x * uScale, 1.0),
    mod(uColor.g - pos.y * uScale, 1.0),
    mod(uColor.b - (pos.x + pos.y) * uScale, 1.0),
    uColor.a
  );
}
