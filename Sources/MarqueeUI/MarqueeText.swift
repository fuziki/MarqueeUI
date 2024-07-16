//
//  MarqueeText.swift
//  MarqueeUI
//
//  Created by fuziki on 2024/07/15.
//

import SwiftUI

public struct MarqueeText: View {
    private let text: String
    private let spacing: CGFloat
    private var animation: ((CGFloat) -> Animation)?

    public init(text: String, spacing: CGFloat = 32) {
        self.text = text
        self.spacing = spacing
    }

    public var body: some View {
        Marquee(spacing: spacing) {
            Text(text)
                .lineLimit(1)
        }
        .animation(withContentWidth: animation)
    }

    public func animation(withContentWidth animation: @escaping (CGFloat) -> Animation) -> Self {
        var result = self
        result.animation = animation
        return result
    }
}

struct Marquee<Content: View>: View {
    private let defaultAnimation: (CGFloat) -> Animation = { contentWidth in
        .linear(duration: contentWidth / 100)
        .delay(1)
        .repeatForever(autoreverses: false)
    }

    private let spacing: CGFloat
    private let content: () -> Content
    private var animation: ((CGFloat) -> Animation)?

    @State private  var animate: Bool = false

    init(spacing: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .hidden()
            .overlay(alignment: .leading) {
                GeometryReader { container in
                    content()
                        .fixedSize(horizontal: true, vertical: false)
                        .hidden()
                        .overlay(alignment: .leading) {
                            GeometryReader { geometry in
                                let contentWidth = geometry.size.width
                                if contentWidth > container.size.width {
                                    HStack(spacing: spacing) {
                                        content()
                                        content()
                                    }
                                    .frame(width: contentWidth * 2 + spacing)
                                    .offset(x: animate ? -(contentWidth + spacing) : 0, y: 0)
                                    .animation(
                                        animation?(contentWidth) ?? defaultAnimation(contentWidth),
                                        value: animate
                                    )
                                    .onAppear {
                                        animate = true
                                    }
                                } else {
                                    content()
                                }
                            }
                        }
                }
            }
            .clipped()
    }

    func animation(withContentWidth animation: ((CGFloat) -> Animation)?) -> Self {
        var result = self
        result.animation = animation
        return result
    }
}

#Preview {
    VStack {
        MarqueeText(text: "Short Text!")
        MarqueeText(text: "Long Text with Default Speed Scroll Animation!")
        MarqueeText(text: "Long Text with High Speed Scroll Animation!")
            .animation { contentWidth in
                .linear(duration: contentWidth / 200)
                .delay(0.5)
                .repeatForever(autoreverses: false)
            }
        MarqueeText(text: "Long Text with Sufficient Space!", spacing: 180)
    }
    .font(.title)
    .padding()
}
