import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarItem? = .sandbox
    
    enum SidebarItem: Hashable {
        case sandbox
        case setupGuide
        case trends
        case diagnostics
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: SidebarItem.sandbox) {
                    Label("Repo Sandbox", systemImage: "testtube.2")
                }
                
                NavigationLink(value: SidebarItem.setupGuide) {
                    Label("Setup Guide", systemImage: "book.fill")
                }
                
                NavigationLink(value: SidebarItem.trends) {
                    Label("Trends & History", systemImage: "chart.xyaxis.line")
                }
                
                NavigationLink(value: SidebarItem.diagnostics) {
                    Label("Diagnostics", systemImage: "stethoscope")
                }
            }
            .navigationTitle("Github Counter")
        } detail: {
            if let selection = selection {
                switch selection {
                case .sandbox:
                    RepoSandboxView()
                case .setupGuide:
                    SetupGuideView()
                case .trends:
                    TrendsView()
                case .diagnostics:
                    DiagnosticsView()
                }
            } else {
                Text("Select an item from the sidebar")
                    .foregroundColor(.secondary)
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
