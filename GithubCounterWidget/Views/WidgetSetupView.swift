import SwiftUI
import WidgetKit

struct WidgetSetupView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "gearshape")
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
                .padding(.bottom, 2)
            
            Text("Configure Repository")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Right-click → Edit Widget")
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
