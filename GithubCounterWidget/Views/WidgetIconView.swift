//
//  WidgetIconView.swift
//  GitCounter
//
//  Copyright © 2026 Black Pinion LLC. All rights reserved.
//

import SwiftUI

struct WidgetIconView: View {
    var size: CGFloat = 16
    
    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            
            ZStack {
                // Left Chevron
                Path { path in
                    path.move(to: CGPoint(x: w * 0.35, y: h * 0.2))
                    path.addLine(to: CGPoint(x: w * 0.1, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.35, y: h * 0.8))
                }
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: w * 0.1, lineCap: .round, lineJoin: .round))
                .shadow(color: Color.cyan.opacity(0.8), radius: w * 0.1)
                
                // Right Chevron
                Path { path in
                    path.move(to: CGPoint(x: w * 0.65, y: h * 0.2))
                    path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.5))
                    path.addLine(to: CGPoint(x: w * 0.65, y: h * 0.8))
                }
                .stroke(Color.cyan, style: StrokeStyle(lineWidth: w * 0.1, lineCap: .round, lineJoin: .round))
                .shadow(color: Color.cyan.opacity(0.8), radius: w * 0.1)
                
                // Zigzag Line
                Path { path in
                    path.move(to: CGPoint(x: w * 0.15, y: h * 0.85))
                    path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.4))
                    path.addLine(to: CGPoint(x: w * 0.6, y: h * 0.65))
                    path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.2))
                }
                .stroke(
                    LinearGradient(colors: [.cyan, .purple, .pink], startPoint: .bottomLeading, endPoint: .topTrailing),
                    style: StrokeStyle(lineWidth: w * 0.12, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: Color.purple.opacity(0.8), radius: w * 0.1)
            }
        }
        .frame(width: size, height: size)
    }
}
