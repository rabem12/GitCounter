import Foundation

class HistoryManager {
    static let shared = HistoryManager()
    
    private init() {}
    
    private var sharedDefaults: UserDefaults {
        if Bundle.main.bundleIdentifier == "io.githubcounter.GithubCounterApp.Widget" {
            return UserDefaults.standard
        } else {
            let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget"
            return UserDefaults(suiteName: path) ?? UserDefaults.standard
        }
    }
    
    func getAvailableRepos() -> [(owner: String, repo: String)] {
        guard let dict = sharedDefaults.dictionaryRepresentation() as? [String: Any] else { return [] }
        var result: [(String, String)] = []
        for key in dict.keys where key.hasPrefix("history_snapshots_") {
            let parts = key.replacingOccurrences(of: "history_snapshots_", with: "").split(separator: "_", maxSplits: 1)
            if parts.count == 2 {
                result.append((String(parts[0]), String(parts[1])))
            }
        }
        return result
    }
}

print(HistoryManager.shared.getAvailableRepos())
