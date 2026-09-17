import Foundation

struct GitHubRelease: Codable {
    let tagName: String
    let draft: Bool
    let prerelease: Bool
    let assets: [GitHubAsset]
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case draft
        case prerelease
        case assets
    }
}

struct GitHubAsset: Codable {
    let name: String
    let downloadCount: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case downloadCount = "download_count"
    }
}

struct RepoStats: Codable, Equatable {
    let owner: String
    let repo: String
    let totalDownloads: Int
    let latestReleaseVersion: String
    let latestReleaseDownloads: Int
    let lastRefreshed: Date
    let isCached: Bool
    
    // New Traffic Metrics
    let totalClones: Int
    let uniqueCloners: Int
    let totalViews: Int
    let uniqueVisitors: Int
    
    // New Public Metrics
    let stars: Int
    let forks: Int
    let openIssues: Int
    
    let downloadsToday: Int?
    let downloadsThisWeek: Int?
    let clonesToday: Int?
    let clonesThisWeek: Int?
    let viewsToday: Int?
    let viewsThisWeek: Int?
    
    let isTrafficAuthorized: Bool
    
    init(owner: String, repo: String, totalDownloads: Int, latestReleaseVersion: String, latestReleaseDownloads: Int, lastRefreshed: Date, isCached: Bool, totalClones: Int = 0, uniqueCloners: Int = 0, totalViews: Int = 0, uniqueVisitors: Int = 0, stars: Int = 0, forks: Int = 0, openIssues: Int = 0, downloadsToday: Int? = nil, downloadsThisWeek: Int? = nil, clonesToday: Int? = nil, clonesThisWeek: Int? = nil, viewsToday: Int? = nil, viewsThisWeek: Int? = nil, isTrafficAuthorized: Bool = true) {
        self.owner = owner
        self.repo = repo
        self.totalDownloads = totalDownloads
        self.latestReleaseVersion = latestReleaseVersion
        self.latestReleaseDownloads = latestReleaseDownloads
        self.lastRefreshed = lastRefreshed
        self.isCached = isCached
        self.totalClones = totalClones
        self.uniqueCloners = uniqueCloners
        self.totalViews = totalViews
        self.uniqueVisitors = uniqueVisitors
        self.stars = stars
        self.forks = forks
        self.openIssues = openIssues
        self.downloadsToday = downloadsToday
        self.downloadsThisWeek = downloadsThisWeek
        self.clonesToday = clonesToday
        self.clonesThisWeek = clonesThisWeek
        self.viewsToday = viewsToday
        self.viewsThisWeek = viewsThisWeek
        self.isTrafficAuthorized = isTrafficAuthorized
    }
    
    var formattedTotalDownloads: String {
        Self.format(number: totalDownloads)
    }
    
    var formattedReleaseVersion: String {
        latestReleaseVersion.lowercased().hasPrefix("v") ? latestReleaseVersion : "v\(latestReleaseVersion)"
    }
    
    var formattedLatestDownloads: String {
        Self.format(number: latestReleaseDownloads)
    }
    
    var formattedTotalClones: String {
        Self.format(number: totalClones)
    }
    
    var formattedTotalViews: String {
        Self.format(number: totalViews)
    }
    
    var formattedDeltaToday: String? {
        guard let today = downloadsToday else { return nil }
        return "+\(NumberFormatter.localizedString(from: NSNumber(value: today), number: .decimal))"
    }
    
    var formattedDeltaWeek: String? {
        guard let week = downloadsThisWeek else { return nil }
        return "+\(NumberFormatter.localizedString(from: NSNumber(value: week), number: .decimal))"
    }

    var formattedClonesToday: String? {
        guard let today = clonesToday else { return nil }
        return "+\(NumberFormatter.localizedString(from: NSNumber(value: today), number: .decimal))"
    }

    var formattedViewsToday: String? {
        guard let today = viewsToday else { return nil }
        return "+\(NumberFormatter.localizedString(from: NSNumber(value: today), number: .decimal))"
    }
    
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    private static func format(number: Int) -> String {
        if number >= 1_000_000_000 {
            return "\(formatter.string(from: NSNumber(value: Double(number) / 1_000_000_000.0)) ?? "")B"
        } else if number >= 1_000_000 {
            return "\(formatter.string(from: NSNumber(value: Double(number) / 1_000_000.0)) ?? "")M"
        } else if number >= 1_000 {
            return "\(formatter.string(from: NSNumber(value: Double(number) / 1_000.0)) ?? "")K"
        } else {
            return "\(number)"
        }
    }
}

extension RepoStats {
    var deepLinkURL: URL {
        var components = URLComponents()
        components.scheme = "githubcounter"
        components.host = "launch"
        components.queryItems = [
            URLQueryItem(name: "owner", value: owner),
            URLQueryItem(name: "repo", value: repo)
        ]
        return components.url ?? URL(string: "githubcounter://launch")!
    }
}
