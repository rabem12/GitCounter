import SwiftUI

@main
struct GithubCounterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 500)
                .onOpenURL { url in
                    if url.scheme == "githubcounter" && url.host == "launch" {
                        // Extract owner and repo from the URL
                        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                           let queryItems = components.queryItems {
                            
                            let owner = queryItems.first(where: { $0.name == "owner" })?.value
                            let repo = queryItems.first(where: { $0.name == "repo" })?.value
                            
                            if let owner = owner, let repo = repo {
                                SharedPreferences.shared.savedOwner = owner
                                SharedPreferences.shared.savedRepo = repo
                            }
                        }
                        
                        // Post the deep link notification so the app knows to switch to Trends
                        NotificationCenter.default.post(name: .didReceiveDeepLink, object: nil)
                    }
                }
        }
    }
}
