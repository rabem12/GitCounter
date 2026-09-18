import SwiftUI

struct DiagnosticsView: View {
    @StateObject private var manager = DiagnosticsManager.shared
    
    // Set to false for distribution builds to hide developer routing logs from the UI
    private let showRoutingLogs = false
    
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
                
                if showRoutingLogs {
                    Section(header: Text("Deep Link Routing Logs").font(.headline)) {
                        if manager.routingLogs.isEmpty {
                            Text("No routing logs yet. (If this remains empty after clicking a widget, the OS is failing to deliver the URL to the app).")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.secondary)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(manager.routingLogs, id: \.self) { log in
                                    Text(log)
                                        .font(.system(.caption, design: .monospaced))
                                        .textSelection(.enabled)
                                    Divider()
                                }
                            }
                        }
                    }
                }
                
                if !manager.coreFiles.isEmpty {
                    Section(header: Text("Core App Data").font(.headline)) {
                        ForEach(manager.coreFiles, id: \.self) { file in
                            HStack {
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
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                }
                
                if !manager.cacheFiles.isEmpty {
                    Section(header: Text("Cached Data & History").font(.headline)) {
                        ForEach(manager.cacheFiles, id: \.self) { file in
                            HStack {
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
                                
                                Spacer()
                                
                                Button(action: {
                                    manager.deleteFile(named: file)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Divider()
                    .padding(.top, 8)
                
                Text("Git and the Git logo are trademarks of Software Freedom Conservancy, Inc. GitCounter is an independent tool and is not affiliated with Software Freedom Conservancy or GitHub, Inc.")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
            .padding()
        }
        .onAppear {
            manager.refresh()
        }
    }
}
