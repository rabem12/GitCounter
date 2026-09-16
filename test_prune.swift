import Foundation

struct DownloadSnapshot: Codable {
    let date: Date
    let totalDownloads: Int
    let latestReleaseDownloads: Int
    let version: String
}

func prune(snapshots: [DownloadSnapshot], now: Date = Date()) -> [DownloadSnapshot] {
    var kept: [DownloadSnapshot] = []
    
    // Sort chronologically just in case
    let sorted = snapshots.sorted { $0.date < $1.date }
    
    // Time boundaries
    let hours48: TimeInterval = 48 * 3600
    let days30: TimeInterval = 30 * 24 * 3600
    let days365: TimeInterval = 365 * 24 * 3600
    
    // To keep track of buckets
    var dailyBuckets: [String: DownloadSnapshot] = [:]
    var weeklyBuckets: [String: DownloadSnapshot] = [:]
    
    let calendar = Calendar.current
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    for snapshot in sorted {
        let age = now.timeIntervalSince(snapshot.date)
        
        if age < 0 { continue } // future?
        
        if age <= hours48 {
            // Keep all
            kept.append(snapshot)
        } else if age <= days30 {
            // Keep one per day (last one of the day)
            let dayKey = dateFormatter.string(from: snapshot.date)
            dailyBuckets[dayKey] = snapshot
        } else if age <= days365 {
            // Keep one per week (last one of the week)
            let comp = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: snapshot.date)
            let weekKey = "\(comp.yearForWeekOfYear ?? 0)-W\(comp.weekOfYear ?? 0)"
            weeklyBuckets[weekKey] = snapshot
        }
        // > 365 days is dropped
    }
    
    // Combine all
    kept.append(contentsOf: dailyBuckets.values)
    kept.append(contentsOf: weeklyBuckets.values)
    
    return kept.sorted { $0.date < $1.date }
}

let now = Date()
var snapshots: [DownloadSnapshot] = []

// Add some < 48h
snapshots.append(DownloadSnapshot(date: now.addingTimeInterval(-3600), totalDownloads: 1, latestReleaseDownloads: 1, version: "v1"))
snapshots.append(DownloadSnapshot(date: now.addingTimeInterval(-7200), totalDownloads: 1, latestReleaseDownloads: 1, version: "v1"))

// Add some 5 days ago (should keep 1 per day)
snapshots.append(DownloadSnapshot(date: now.addingTimeInterval(-86400 * 5), totalDownloads: 1, latestReleaseDownloads: 1, version: "v1"))
snapshots.append(DownloadSnapshot(date: now.addingTimeInterval(-86400 * 5 - 3600), totalDownloads: 1, latestReleaseDownloads: 1, version: "v1"))

// Add some 60 days ago (should keep 1 per week)
snapshots.append(DownloadSnapshot(date: now.addingTimeInterval(-86400 * 60), totalDownloads: 1, latestReleaseDownloads: 1, version: "v1"))
snapshots.append(DownloadSnapshot(date: now.addingTimeInterval(-86400 * 62), totalDownloads: 1, latestReleaseDownloads: 1, version: "v1")) // same week? maybe

let pruned = prune(snapshots: snapshots, now: now)
print("Original count: \(snapshots.count)")
print("Pruned count: \(pruned.count)")
for p in pruned {
    print("\(p.date) - \(now.timeIntervalSince(p.date) / 86400) days ago")
}
