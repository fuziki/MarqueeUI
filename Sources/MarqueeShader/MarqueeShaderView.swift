//
//  MarqueeShaderView.swift
//
//
//  Created by fuziki on 2024/07/24.
//

import SwiftUI

@available(iOS 17, *)
public struct MarqueeShaderView<Content: View>: View {
    private let spacing: CGFloat
    private let pointsPerSec: CGFloat
    private let delaySec: CGFloat
    private let content: () -> Content
    @State private var start = Date()

    public init(
        spacing: CGFloat = 32,
        pointsPerSec: CGFloat = 128,
        delaySec: CGFloat = 1,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.spacing = spacing
        self.pointsPerSec = pointsPerSec
        self.delaySec = delaySec
        self.content = content
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let sec = context.date.timeIntervalSince1970 - start.timeIntervalSince1970
            content()
                .geometryGroup()
                .visualEffect { content, geometryProxy in
                    content.distortionEffect(
                        ShaderLibrary.bundle(.module).translate
                            .dynamicallyCall(withArguments: [
                                .float2(calcOffset(sec: sec, geometryProxy: geometryProxy)),
                                .float2(geometryProxy.size.width + spacing, geometryProxy.size.height)
                            ]),
                        maxSampleOffset: .zero
                    )
                }
        }
    }

    private func calcOffset(sec: TimeInterval, geometryProxy: GeometryProxy) -> CGPoint {
        let width = geometryProxy.size.width + spacing
        let moveSec = width / pointsPerSec
        let duration = abs(moveSec) + delaySec
        let offset = max(0, sec.truncatingRemainder(dividingBy: duration) - delaySec)
        return .init(x: width * offset / moveSec, y: 0)
    }
}

@available(iOS 17, *)
#Preview {
    VStack {
        MarqueeShaderView(pointsPerSec: 128) {
            Text("Long Text with MarqueeShaderView!")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.red)
                .border(Color.black)
        }
        MarqueeShaderView(pointsPerSec: -128) {
            Text("Long Text with MarqueeShaderView!")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.red)
                .border(Color.black)
        }
    }
    .padding()
    .background(Color.blue)
}

