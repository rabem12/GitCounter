import AppIntents
import Foundation
import AppKit

struct OpenRepoIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Repository"
    
    @Parameter(title: "Owner") var owner: String
    @Parameter(title: "Repo") var repo: String
    
    init() {}
    
    init(owner: String, repo: String) {
        self.owner = owner
        self.repo = repo
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // Write file...
        NSWorkspace.shared.open(URL(string: "githubcounter://launch")!)
        return .result()
    }
}
