import Foundation

struct DownloadSnapshot: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let totalDownloads: Int
    let latestReleaseDownloads: Int
    let version: String
    
    // Traffic metrics (optional for backward compatibility)
    var totalClones: Int?
    var uniqueCloners: Int?
    var totalViews: Int?
    var uniqueVisitors: Int?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalDownloads: Int,
        latestReleaseDownloads: Int,
        version: String,
        totalClones: Int? = nil,
        uniqueCloners: Int? = nil,
        totalViews: Int? = nil,
        uniqueVisitors: Int? = nil
    ) {
        self.id = id
        self.date = date
        self.totalDownloads = totalDownloads
        self.latestReleaseDownloads = latestReleaseDownloads
        self.version = version
        self.totalClones = totalClones
        self.uniqueCloners = uniqueCloners
        self.totalViews = totalViews
        self.uniqueVisitors = uniqueVisitors
    }
}
