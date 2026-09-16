import AppKit

let symbols = ["chart.line.uptrend.xyaxis", "chart.xyaxis.line", "waveform.path", "bolt.fill"]
for s in symbols {
    if NSImage(systemSymbolName: s, accessibilityDescription: nil) != nil {
        print("FOUND: \(s)")
    } else {
        print("MISSING: \(s)")
    }
}
