import SwiftUI

struct DiagnosticsView: View {
    @StateObject private var manager = DiagnosticsManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    Text("Diagnostics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Refresh") {
                        manager.refresh()
                    }
                }
                
                Section(header: Text("App Context").font(.headline)) {
                    Text(manager.mainAppDirectory)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                }
                
                Section(header: Text("Widget Shared Directory").font(.headline)) {
                    Text(manager.widgetDirectory)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                }
                
                Section(header: Text("Last Opened URL").font(.headline)) {
                    Text(manager.lastOpenedURL)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                }
                
                Section(header: Text("Files Found").font(.headline)) {
                    ForEach(manager.filesInSharedDirectory, id: \.self) { file in
                        VStack(alignment: .leading) {
                            Text(file)
                                .font(.system(.body, design: .monospaced))
                                .bold()
                            
                            if let content = manager.fileContents[file] {
                                Text(content)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            manager.refresh()
        }
    }
}
