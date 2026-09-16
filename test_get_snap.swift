import Foundation

struct DownloadSnapshot: Codable, Identifiable {
    let id: UUID
    let date: Date
    let totalDownloads: Int
    let latestReleaseDownloads: Int
    let version: String
    
    init(date: Date, totalDownloads: Int, latestReleaseDownloads: Int, version: String) {
        self.id = UUID()
        self.date = date
        self.totalDownloads = totalDownloads
        self.latestReleaseDownloads = latestReleaseDownloads
        self.version = version
    }
}

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
    
    func getSnapshots(owner: String, repo: String) -> [DownloadSnapshot] {
        let key = "history_snapshots_\(owner.lowercased())_\(repo.lowercased())"
        guard let data = sharedDefaults.data(forKey: key),
              let snapshots = try? JSONDecoder().decode([DownloadSnapshot].self, from: data) else {
            return []
        }
        return snapshots.sorted(by: { $0.date < $1.date })
    }
}

let snapshots = HistoryManager.shared.getSnapshots(owner: "obsproject", repo: "obs-studio")
print("Found \(snapshots.count) snapshots for obsproject/obs-studio")
