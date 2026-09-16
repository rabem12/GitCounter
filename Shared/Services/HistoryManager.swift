import Foundation

struct StatsDeltas {
    let downloadsToday: Int?
    let downloadsThisWeek: Int?
    let clonesToday: Int?
    let clonesThisWeek: Int?
    let viewsToday: Int?
    let viewsThisWeek: Int?
}

class HistoryManager {
    static let shared = HistoryManager()
    
    private init() {}
    
    private func getDocumentsDirectory() -> URL {
        if Bundle.main.bundleIdentifier == "io.githubcounter.GithubCounterApp.Widget" {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        } else {
            let path = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Documents"
            return URL(fileURLWithPath: path)
        }
    }
    
    private func getLegacyDictionary() -> [String: Any]? {
        if Bundle.main.bundleIdentifier == "io.githubcounter.GithubCounterApp.Widget" {
            let ud = UserDefaults.standard
            ud.synchronize()
            return ud.dictionaryRepresentation()
        } else {
            let path = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
            return NSDictionary(contentsOfFile: path) as? [String: Any]
        }
    }

    private func getSharedJSONURL(forKey key: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent("\(key).json")
    }
    
    func getAvailableRepos() -> [(owner: String, repo: String)] {
        var result: [(owner: String, repo: String)] = []
        
        // 1. Try to read from the manifest file first (bypasses macOS directory enumeration TCC limits)
        let manifestURL = getDocumentsDirectory().appendingPathComponent("repos_manifest.json")
        if let data = try? Data(contentsOf: manifestURL),
           let manifest = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            for item in manifest {
                if let owner = item["owner"], let repo = item["repo"] {
                    result.append((owner: owner, repo: repo))
                }
            }
        } else {
            // Fallback: try contentsOfDirectory (may fail if unsandboxed app lacks Full Disk Access)
            let dir = getDocumentsDirectory()
            if let files = try? FileManager.default.contentsOfDirectory(atPath: dir.path) {
                for file in files where file.hasPrefix("history_snapshots_") && file.hasSuffix(".json") {
                    let name = (file as NSString).deletingPathExtension
                    let parts = name.replacingOccurrences(of: "history_snapshots_", with: "").split(separator: "_", maxSplits: 1)
                    if parts.count == 2 {
                        let owner = String(parts[0])
                        let repo = String(parts[1])
                        if !result.contains(where: { $0.owner == owner && $0.repo == repo }) {
                            result.append((owner: owner, repo: repo))
                        }
                    }
                }
            }
        }
        
        // 2. Get from old UserDefaults (unmigrated data)
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
    
    private func updateManifest(owner: String, repo: String) {
        var repos = getAvailableRepos()
        if !repos.contains(where: { $0.owner == owner && $0.repo == repo }) {
            repos.append((owner: owner, repo: repo))
            repos.sort { $0.owner < $1.owner }
            
            let manifestArray = repos.map { ["owner": $0.owner, "repo": $0.repo] }
            let manifestURL = getDocumentsDirectory().appendingPathComponent("repos_manifest.json")
            if let data = try? JSONSerialization.data(withJSONObject: manifestArray) {
                try? data.write(to: manifestURL, options: .atomic)
            }
        }
    }
    
    private func getKey(owner: String, repo: String) -> String {
        return "history_snapshots_\(owner.lowercased())_\(repo.lowercased())"
    }
    
    func recordSnapshot(owner: String, repo: String, stats: RepoStats) {
        var snapshots = getSnapshots(owner: owner, repo: repo)
        
        let newSnapshot = DownloadSnapshot(
            date: Date(),
            totalDownloads: stats.totalDownloads,
            latestReleaseDownloads: stats.latestReleaseDownloads,
            version: stats.latestReleaseVersion,
            totalClones: stats.totalClones,
            uniqueCloners: stats.uniqueCloners,
            totalViews: stats.totalViews,
            uniqueVisitors: stats.uniqueVisitors
        )
        
        // Skip redundant snapshots if under 15 minutes old and no total change
        if let last = snapshots.last {
            if Date().timeIntervalSince(last.date) < 15 * 60 && last.totalDownloads == newSnapshot.totalDownloads {
                return
            }
        }
        
        snapshots.append(newSnapshot)
        
        // Prune to 365 days max, keep first and last per day
        snapshots = prune(snapshots: snapshots)
        
        save(snapshots: snapshots, owner: owner, repo: repo)
        updateManifest(owner: owner, repo: repo)
    }
    
    func calculateDeltas(owner: String, repo: String, currentDownloads: Int, currentClones: Int, currentViews: Int) -> StatsDeltas {
        let snapshots = getSnapshots(owner: owner, repo: repo)
        if snapshots.isEmpty {
            return StatsDeltas(downloadsToday: nil, downloadsThisWeek: nil, clonesToday: nil, clonesThisWeek: nil, viewsToday: nil, viewsThisWeek: nil)
        }
        
        let now = Date()
        let past24h = now.addingTimeInterval(-86400)
        let past7d = now.addingTimeInterval(-86400 * 7)
        
        var todaySnapshot: DownloadSnapshot? = nil
        var weekSnapshot: DownloadSnapshot? = nil
        
        // Find closest snapshot around 24h ago
        for snapshot in snapshots.reversed() {
            if snapshot.date <= past24h {
                todaySnapshot = snapshot
                break
            }
        }
        
        // Find closest snapshot around 7d ago
        for snapshot in snapshots.reversed() {
            if snapshot.date <= past7d {
                weekSnapshot = snapshot
                break
            }
        }
        
        // If we don't have exactly 24h/7d, take the oldest one we have for that window
        if todaySnapshot == nil, let oldest = snapshots.first, oldest.date < now.addingTimeInterval(-3600) {
            todaySnapshot = oldest
        }
        
        if weekSnapshot == nil, let oldest = snapshots.first, oldest.date < now.addingTimeInterval(-86400) {
            weekSnapshot = oldest
        }
        
        let todayDelta = todaySnapshot.map { max(0, currentDownloads - $0.totalDownloads) }
        let weekDelta = weekSnapshot.map { max(0, currentDownloads - $0.totalDownloads) }
        
        let clonesTodayDelta = todaySnapshot.map { max(0, currentClones - ($0.totalClones ?? 0)) }
        let clonesWeekDelta = weekSnapshot.map { max(0, currentClones - ($0.totalClones ?? 0)) }
        
        let viewsTodayDelta = todaySnapshot.map { max(0, currentViews - ($0.totalViews ?? 0)) }
        let viewsWeekDelta = weekSnapshot.map { max(0, currentViews - ($0.totalViews ?? 0)) }
        
        return StatsDeltas(
            downloadsToday: todayDelta,
            downloadsThisWeek: weekDelta,
            clonesToday: clonesTodayDelta,
            clonesThisWeek: clonesWeekDelta,
            viewsToday: viewsTodayDelta,
            viewsThisWeek: viewsWeekDelta
        )
    }
    
    func getSnapshots(owner: String, repo: String) -> [DownloadSnapshot] {
        let key = getKey(owner: owner, repo: repo)
        let url = getSharedJSONURL(forKey: key)
        
        // 1. Try to read from the new JSON file
        if let data = try? Data(contentsOf: url),
           let snapshots = try? JSONDecoder().decode([DownloadSnapshot].self, from: data) {
            return snapshots.sorted(by: { $0.date < $1.date })
        }
        
        // 2. Automatic Migration: If JSON is missing, grab the old UserDefaults data
        if let dict = getLegacyDictionary(),
           let oldData = dict[key] as? Data,
           let oldSnapshots = try? JSONDecoder().decode([DownloadSnapshot].self, from: oldData) {
            
            // Save it to JSON immediately
            save(snapshots: oldSnapshots, owner: owner, repo: repo)
            
            // We do not remove the old object from the plist manually when read from the main app, 
            // as rewriting the plist from the main app might break the widget's defaults system.
            // The widget will eventually clear it, or it will just be ignored since JSON is now preferred.
            if Bundle.main.bundleIdentifier == "io.githubcounter.GithubCounterApp.Widget" {
                UserDefaults.standard.removeObject(forKey: key)
            }
            
            return oldSnapshots.sorted(by: { $0.date < $1.date })
        }
        
        return []
    }
    
    private func save(snapshots: [DownloadSnapshot], owner: String, repo: String) {
        let key = getKey(owner: owner, repo: repo)
        let url = getSharedJSONURL(forKey: key)
        
        do {
            let dir = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            
            let data = try JSONEncoder().encode(snapshots)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Failed to save History JSON: \(error)")
        }
    }
    
    private func prune(snapshots: [DownloadSnapshot]) -> [DownloadSnapshot] {
        var kept: [DownloadSnapshot] = []
        let now = Date()
        
        // Time boundaries
        let hours48: TimeInterval = 48 * 3600
        let days30: TimeInterval = 30 * 24 * 3600
        
        var dailyBuckets: [String: DownloadSnapshot] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Sort chronologically (oldest to newest)
        let sorted = snapshots.sorted { $0.date < $1.date }
        
        for snapshot in sorted {
            let age = now.timeIntervalSince(snapshot.date)
            
            if age < 0 { continue } // skip future dates if any
            
            if age <= hours48 {
                kept.append(snapshot)
            } else if age <= days30 {
                // Keep the latest snapshot for each day
                let dayKey = dateFormatter.string(from: snapshot.date)
                dailyBuckets[dayKey] = snapshot
            }
            // Anything older than 30 days is discarded to save disk space
        }
        
        kept.append(contentsOf: dailyBuckets.values)
        
        return kept.sorted { $0.date < $1.date }
    }
    
    func exportCSV(owner: String, repo: String) -> URL? {
        let snapshots = getSnapshots(owner: owner, repo: repo)
        var csv = "Date,Total Downloads,Latest Release Downloads,Version,Total Clones,Unique Cloners,Total Views,Unique Visitors\n"
        
        let isoFormatter = ISO8601DateFormatter()
        
        for snapshot in snapshots {
            let dateStr = isoFormatter.string(from: snapshot.date)
            let clones = snapshot.totalClones ?? 0
            let uClones = snapshot.uniqueCloners ?? 0
            let views = snapshot.totalViews ?? 0
            let uViews = snapshot.uniqueVisitors ?? 0
            
            csv += "\(dateStr),\(snapshot.totalDownloads),\(snapshot.latestReleaseDownloads),\(snapshot.version),\(clones),\(uClones),\(views),\(uViews)\n"
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(owner)_\(repo)_downloads.csv")
        
        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            return nil
        }
    }
    
    private func removeFromManifest(owner: String, repo: String) {
        var repos = getAvailableRepos()
        if let index = repos.firstIndex(where: { $0.owner == owner && $0.repo == repo }) {
            repos.remove(at: index)
            let manifestArray = repos.map { ["owner": $0.owner, "repo": $0.repo] }
            let manifestURL = getDocumentsDirectory().appendingPathComponent("repos_manifest.json")
            if let data = try? JSONSerialization.data(withJSONObject: manifestArray) {
                try? data.write(to: manifestURL, options: .atomic)
            }
        }
    }
    
    func clearHistory(owner: String, repo: String) {
        let key = getKey(owner: owner, repo: repo)
        let url = getSharedJSONURL(forKey: key)
        try? FileManager.default.removeItem(at: url)
        
        removeFromManifest(owner: owner, repo: repo)
        
        // Also clean up old user defaults
        if Bundle.main.bundleIdentifier == "io.githubcounter.GithubCounterApp.Widget" {
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            let path = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
            if let dict = NSMutableDictionary(contentsOfFile: path) {
                dict.removeObject(forKey: key)
                dict.write(toFile: path, atomically: true)
            }
        }
    }
    
    func ingestCSV(csvString: String, owner: String, repo: String) {
        var existing = getSnapshots(owner: owner, repo: repo)
        let lines = csvString.components(separatedBy: .newlines)
        
        let isoFormatter = ISO8601DateFormatter()
        
        // Skip header
        for (index, line) in lines.enumerated() {
            if index == 0 && line.contains("Date,") { continue }
            
            let parts = line.components(separatedBy: ",")
            if parts.count >= 4 {
                if let date = isoFormatter.date(from: parts[0]),
                   let total = Int(parts[1]),
                   let latest = Int(parts[2]) {
                    let version = parts[3]
                    
                    var totalClones: Int? = nil
                    var uniqueCloners: Int? = nil
                    var totalViews: Int? = nil
                    var uniqueVisitors: Int? = nil
                    
                    if parts.count >= 8 {
                        totalClones = Int(parts[4])
                        uniqueCloners = Int(parts[5])
                        totalViews = Int(parts[6])
                        uniqueVisitors = Int(parts[7])
                    }
                    
                    if !existing.contains(where: { $0.date == date && $0.totalDownloads == total }) {
                        existing.append(DownloadSnapshot(
                            date: date,
                            totalDownloads: total,
                            latestReleaseDownloads: latest,
                            version: version,
                            totalClones: totalClones,
                            uniqueCloners: uniqueCloners,
                            totalViews: totalViews,
                            uniqueVisitors: uniqueVisitors
                        ))
                    }
                }
            }
        }
        
        existing.sort(by: { $0.date < $1.date })
        save(snapshots: prune(snapshots: existing), owner: owner, repo: repo)
    }
}
