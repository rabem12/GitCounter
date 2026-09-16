import Foundation
import os

class CacheManager {
    static let shared = CacheManager()
    private let logger = OSLog(subsystem: "io.githubcounter.GithubCounterApp", category: "CacheManager")
    
    private init() {}
    
    private func getDocumentsDirectory() -> URL {
        if Bundle.main.bundleIdentifier == "io.githubcounter.GithubCounterApp.Widget" {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        } else {
            let path = "/Users/\(NSUserName())/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Documents"
            return URL(fileURLWithPath: path)
        }
    }
    
    private func getLegacyDictionary() -> [String: Any]? {
        if Bundle.main.bundleIdentifier == "io.githubcounter.GithubCounterApp.Widget" {
            let ud = UserDefaults.standard
            ud.synchronize()
            return ud.dictionaryRepresentation()
        } else {
            let path = "/Users/\(NSUserName())/Library/Containers/io.githubcounter.GithubCounterApp.Widget/Data/Library/Preferences/io.githubcounter.GithubCounterApp.Widget.plist"
            return NSDictionary(contentsOfFile: path) as? [String: Any]
        }
    }

    private func getSharedJSONURL(forKey key: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent("\(key).json")
    }
    
    private func getKey(owner: String, repo: String) -> String {
        return "releaseStats_\(owner.lowercased())_\(repo.lowercased())"
    }
    
    func save(_ stats: RepoStats) {
        let key = getKey(owner: stats.owner, repo: stats.repo)
        let url = getSharedJSONURL(forKey: key)
        
        do {
            let dir = url.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            
            let data = try JSONEncoder().encode(stats)
            try data.write(to: url, options: .atomic)
            os_log("Successfully saved cache for key: %{public}@", log: self.logger, type: .default, key)
        } catch {
            os_log("FAILED to encode cache for %{public}@: %{public}@", log: self.logger, type: .error, key, error.localizedDescription)
        }
    }
    
    func getCachedStats(owner: String, repo: String) -> RepoStats? {
        let key = getKey(owner: owner, repo: repo)
        let url = getSharedJSONURL(forKey: key)
        
        // 1. Try to read from the new JSON file
        if let data = try? Data(contentsOf: url),
           let stats = try? JSONDecoder().decode(RepoStats.self, from: data) {
            return RepoStats(
                owner: stats.owner,
                repo: stats.repo,
                totalDownloads: stats.totalDownloads,
                latestReleaseVersion: stats.latestReleaseVersion,
                latestReleaseDownloads: stats.latestReleaseDownloads,
                lastRefreshed: stats.lastRefreshed,
                isCached: true // Set isCached to true since we are returning from cache
            )
        }
        
        // 2. Automatic Migration: If JSON is missing, grab the old UserDefaults data
        if let dict = getLegacyDictionary(),
           let oldData = dict[key] as? Data,
           let stats = try? JSONDecoder().decode(RepoStats.self, from: oldData) {
            
            // Save it to JSON immediately
            save(stats)
            
            if Bundle.main.bundleIdentifier == "io.githubcounter.GithubCounterApp.Widget" {
                UserDefaults.standard.removeObject(forKey: key)
            }
            
            return RepoStats(
                owner: stats.owner,
                repo: stats.repo,
                totalDownloads: stats.totalDownloads,
                latestReleaseVersion: stats.latestReleaseVersion,
                latestReleaseDownloads: stats.latestReleaseDownloads,
                lastRefreshed: stats.lastRefreshed,
                isCached: true
            )
        }
        
        return nil
    }
}
