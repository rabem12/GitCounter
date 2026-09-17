import SwiftUI

struct DeepLinkHandler {
    static func handle(_ url: URL, source: String = "onOpenURL") {
        DiagnosticsManager.shared.logOpenedURL(url)
        DiagnosticsManager.shared.logRoutingEvent("[\(source)] received: \(url.absoluteString)")
        
        guard url.scheme == "githubcounter", url.host == "launch" else {
            let schemeStr = url.scheme ?? "nil"
            let hostStr = url.host ?? "nil"
            DiagnosticsManager.shared.logRoutingEvent("URL did NOT match scheme/host: \(schemeStr)://\(hostStr)")
            return
        }
        
        DiagnosticsManager.shared.logRoutingEvent("URL Scheme and Host matched.")
        
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            
            let owner = queryItems.first(where: { $0.name == "owner" })?.value
            let repo = queryItems.first(where: { $0.name == "repo" })?.value
            
            let ownerStr = owner ?? "nil"
            let repoStr = repo ?? "nil"
            DiagnosticsManager.shared.logRoutingEvent("Parsed owner: \(ownerStr), repo: \(repoStr)")
            
            if let owner = owner, !owner.isEmpty, let repo = repo, !repo.isEmpty {
                SharedPreferences.shared.savedOwner = owner
                SharedPreferences.shared.savedRepo = repo
                DiagnosticsManager.shared.logRoutingEvent("Saved \(owner)/\(repo) to SharedPreferences.")
            }
        } else {
            DiagnosticsManager.shared.logRoutingEvent("Failed to parse URLComponents.")
        }
        
        DiagnosticsManager.shared.logRoutingEvent("Posting .didReceiveDeepLink notification...")
        NotificationCenter.default.post(name: .didReceiveDeepLink, object: nil)
    }
}

@main
struct GithubCounterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 500)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
                .onOpenURL { url in
                    DeepLinkHandler.handle(url, source: "onOpenURL")
                }
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }
}
