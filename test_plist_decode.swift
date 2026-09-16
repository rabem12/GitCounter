import Foundation

struct DownloadSnapshot: Codable, Identifiable {
    let id: UUID
    let date: Date
    let totalDownloads: Int
    let latestReleaseDownloads: Int
    let version: String
}

let path = NSHomeDirectory() + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
if let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
   let data = dict["history_snapshots_obsproject_obs-studio"] as? Data {
    if let snapshots = try? JSONDecoder().decode([DownloadSnapshot].self, from: data) {
        print("Successfully decoded \(snapshots.count) snapshots directly from plist!")
    } else {
        print("Failed to decode")
    }
} else {
    print("Could not read dict or data")
}
