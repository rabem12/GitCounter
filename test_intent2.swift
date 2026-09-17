import AppIntents
import Foundation

struct OpenRepoIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Repository"
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Owner") var owner: String
    @Parameter(title: "Repo") var repo: String
    
    init() {}
    
    init(owner: String, repo: String) {
        self.owner = owner
        self.repo = repo
    }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
