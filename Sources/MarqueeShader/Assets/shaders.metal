#include <metal_stdlib>
using namespace metal;
#include <SwiftUI/SwiftUI_Metal.h>

[[ stitchable ]] float2 translate(float2 position,
                                  float2 translation,
                                  float2 frameSize) {
    float x = position.x + translation.x;
    if(x > frameSize.x) x -= frameSize.x;
    if(x < 0) x += frameSize.x;

    float y = position.y + translation.y;
    if(y > frameSize.y) y -= frameSize.y;
    if(y < 0) y += frameSize.y;

    return float2(x, y);
}
