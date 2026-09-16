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
            List(selection: $selection) {
                NavigationLink(value: SidebarItem.trends) {
                    Label("Dashboard", systemImage: "chart.xyaxis.line")
                }
                
                NavigationLink(value: SidebarItem.launchpad) {
                    Label("Launchpad", systemImage: "rocket.fill")
                }
                
                NavigationLink(value: SidebarItem.setupGuide) {
                    Label("Setup Guide", systemImage: "book.fill")
                }
                
                NavigationLink(value: SidebarItem.diagnostics) {
                    Label("Diagnostics", systemImage: "stethoscope")
                }
            }
            .navigationTitle("Github Counter")
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
        .onOpenURL { url in
            handleIncomingURL(url)
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        DiagnosticsManager.shared.logOpenedURL(url)
        
        guard url.scheme == "githubcounter", url.host == "trends" else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let queryItems = components?.queryItems else { return }
        
        var newOwner: String?
        var newRepo: String?
        
        for item in queryItems {
            if item.name == "owner" {
                newOwner = item.value
            } else if item.name == "repo" {
                newRepo = item.value
            }
        }
        
        if let owner = newOwner, let repo = newRepo {
            SharedPreferences.shared.savedOwner = owner
            SharedPreferences.shared.savedRepo = repo
            selection = .trends
        }
    }
}
