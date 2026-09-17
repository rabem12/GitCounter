import AppIntents
import Foundation
import AppKit

struct OpenRepoIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Repository"
    
    // Set openAppWhenRun to true so the system automatically brings the app to the foreground
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Owner") var owner: String
    @Parameter(title: "Repo") var repo: String
    
    init() {}
    
    init(owner: String, repo: String) {
        self.owner = owner
        self.repo = repo
    }
    
    func perform() async throws -> some IntentResult {
        let selectedOwner = self.owner
        let selectedRepo = self.repo
        
        await MainActor.run {
            #if os(macOS)
            // macOS Widget extensions run in a separate process. Modifying SharedPreferences here
            // won't reflect in the main app. We must pass the data via the deep link URL.
            var components = URLComponents()
            components.scheme = "githubcounter"
            components.host = "launch"
            components.queryItems = [
                URLQueryItem(name: "owner", value: selectedOwner),
                URLQueryItem(name: "repo", value: selectedRepo)
            ]
            
            if let url = components.url {
                NSWorkspace.shared.open(url)
            }
            #endif
        }
        
        return .result()
    }
}

extension Notification.Name {
    static let didReceiveDeepLink = Notification.Name("didReceiveDeepLink")
}

