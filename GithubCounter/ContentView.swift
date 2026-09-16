import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarItem? = .trends
    
    enum SidebarItem: Hashable {
        case trends
        case launchpad
        case setupGuide
        case diagnostics
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 4) {
                // Header
                HStack {
                    Image(systemName: "command.square.fill")
                        .font(.title)
                        .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text("Github Counter")
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 12)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                // Primary
                SidebarButton(title: "Dashboard", systemImage: "chart.xyaxis.line", iconColor: .blue, item: .trends, selection: $selection)
                SidebarButton(title: "Launchpad", systemImage: "paperplane.fill", iconColor: .orange, item: .launchpad, selection: $selection)
                
                Spacer()
                
                // Secondary
                SidebarButton(title: "Setup Guide", systemImage: "book.fill", iconColor: .green, item: .setupGuide, selection: $selection)
                SidebarButton(title: "Diagnostics", systemImage: "stethoscope", iconColor: .red, item: .diagnostics, selection: $selection)
            }
            .padding(.bottom, 16)
            .background(Material.ultraThin)
            .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 300)
        } detail: {
            if let selection = selection {
                switch selection {
                case .trends:
                    TrendsView()
                case .launchpad:
                    LaunchpadView()
                case .setupGuide:
                    SetupGuideView()
                case .diagnostics:
                    DiagnosticsView()
                }
            } else {
                Text("Select an item from the sidebar")
                    .foregroundColor(.secondary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Link(destination: URL(string: "https://ko-fi.com/raven_lord")!) {
                    HStack {
                        Text("☕️")
                        Text("Support the Developer")
                            .fontWeight(.medium)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveDeepLink)) { notification in
            if let url = notification.object as? URL {
                handleIncomingURL(url)
            }
        }
        .onAppear {
            AppDelegate.isContentViewReady = true
            if let pending = AppDelegate.pendingWidgetURL {
                AppDelegate.pendingWidgetURL = nil
                AppDelegate.processDeepLink(pending)
            }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        // Only need to switch the tab, as AppDelegate already saved the owner/repo to SharedPreferences
        guard url.scheme == "githubcounter", url.host == "trends" else { return }
        selection = .trends
    }
}

struct SidebarButton: View {
    let title: String
    let systemImage: String
    let iconColor: Color
    let item: ContentView.SidebarItem
    @Binding var selection: ContentView.SidebarItem?
    
    @State private var isHovered = false
    
    var isSelected: Bool {
        selection == item
    }
    
    var body: some View {
        Button(action: {
            selection = item
        }) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : iconColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                ZStack {
                    if isSelected {
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                            .cornerRadius(10)
                    } else if isHovered {
                        Color.primary.opacity(0.1)
                            .cornerRadius(10)
                    }
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
