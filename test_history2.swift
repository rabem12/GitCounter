import Foundation

class HistoryManager {
    static let shared = HistoryManager()
    
    private init() {}
    
    private func getDocumentsDirectory() -> URL {
        let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Documents"
        return URL(fileURLWithPath: path)
    }
    
    private func getLegacyDictionary() -> [String: Any]? {
        let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
        return NSDictionary(contentsOfFile: path) as? [String: Any]
    }
    
    func getAvailableRepos() -> [(owner: String, repo: String)] {
        var result: [(owner: String, repo: String)] = []
        
        let dir = getDocumentsDirectory()
        if let files = try? FileManager.default.contentsOfDirectory(atPath: dir.path) {
            for file in files where file.hasPrefix("history_snapshots_") && file.hasSuffix(".json") {
                let name = (file as NSString).deletingPathExtension
                let parts = name.replacingOccurrences(of: "history_snapshots_", with: "").split(separator: "_", maxSplits: 1)
                if parts.count == 2 {
                    result.append((owner: String(parts[0]), repo: String(parts[1])))
                }
            }
        }
        
        if let dict = getLegacyDictionary() {
            for key in dict.keys where key.hasPrefix("history_snapshots_") {
                let parts = key.replacingOccurrences(of: "history_snapshots_", with: "").split(separator: "_", maxSplits: 1)
                if parts.count == 2 {
                    let owner = String(parts[0])
                    let repo = String(parts[1])
                    if !result.contains(where: { $0.owner == owner && $0.repo == repo }) {
                        result.append((owner: owner, repo: repo))
                    }
                }
            }
        }
        
        return result.sorted { $0.owner < $1.owner }
    }
}

print(HistoryManager.shared.getAvailableRepos())
