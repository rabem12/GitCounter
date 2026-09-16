import SwiftUI

struct LogoView: View {
    var body: some View {
        ZStack {
            // Left Chevron
            Path { path in
                path.move(to: CGPoint(x: 0.4, y: 0.2))
                path.addLine(to: CGPoint(x: 0.1, y: 0.5))
                path.addLine(to: CGPoint(x: 0.4, y: 0.8))
            }
            .stroke(Color.cyan, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            // Right Chevron
            Path { path in
                path.move(to: CGPoint(x: 0.6, y: 0.2))
                path.addLine(to: CGPoint(x: 0.9, y: 0.5))
                path.addLine(to: CGPoint(x: 0.6, y: 0.8))
            }
            .stroke(Color.cyan, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            
            // Zigzag Line
            Path { path in
                path.move(to: CGPoint(x: 0.1, y: 0.85))
                path.addLine(to: CGPoint(x: 0.45, y: 0.35))
                path.addLine(to: CGPoint(x: 0.55, y: 0.6))
                path.addLine(to: CGPoint(x: 0.9, y: 0.15))
            }
            .stroke(Color.purple, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
    }
}
