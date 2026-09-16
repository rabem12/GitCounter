import Foundation

struct GitHubRelease: Codable {
    let tagName: String
    let draft: Bool
    let prerelease: Bool
    let publishedAt: Date?
    let assets: [GitHubAsset]
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case draft
        case prerelease
        case publishedAt = "published_at"
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

struct RepoStats: Codable {
    let owner: String
    let repo: String
    let totalDownloads: Int
    let latestReleaseVersion: String
    let latestReleaseDownloads: Int
    let lastRefreshed: Date
    let isCached: Bool
}

enum GitHubAPIError: Error {
    case invalidURL
    case networkError(Error)
    case rateLimited
    case decodingError(Error)
    case invalidResponse
    case repoNotFound
}

func fetchStats(owner: String, repo: String, pat: String?) async throws -> RepoStats {
    var totalDownloads = 0
    var latestReleaseVersion = "N/A"
    var latestReleaseDownloads = 0
    var page = 1
    var hasMorePages = true
    var isFirstStableReleaseFound = false
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    while hasMorePages {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/releases?per_page=100&page=\(page)"
        guard let url = URL(string: urlString) else {
            throw GitHubAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("GithubCounterWidget/1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GitHubAPIError.invalidResponse
        }
        
        if httpResponse.statusCode == 404 { throw GitHubAPIError.repoNotFound }
        if httpResponse.statusCode == 403 || httpResponse.statusCode == 429 { throw GitHubAPIError.rateLimited }
        guard httpResponse.statusCode == 200 else { throw GitHubAPIError.invalidResponse }
        
        do {
            let releases = try decoder.decode([GitHubRelease].self, from: data)
            if releases.isEmpty {
                hasMorePages = false
                break
            }
            
            for release in releases {
                let releaseDownloads = release.assets.reduce(0) { $0 + $1.downloadCount }
                totalDownloads += releaseDownloads
                
                if !isFirstStableReleaseFound && !release.draft && !release.prerelease {
                    latestReleaseVersion = release.tagName
                    latestReleaseDownloads = releaseDownloads
                    isFirstStableReleaseFound = true
                }
            }
            
            if releases.count < 100 { hasMorePages = false } else { page += 1 }
        } catch {
            throw GitHubAPIError.decodingError(error)
        }
    }
    
    return RepoStats(
        owner: owner, repo: repo, totalDownloads: totalDownloads,
        latestReleaseVersion: latestReleaseVersion, latestReleaseDownloads: latestReleaseDownloads,
        lastRefreshed: Date(), isCached: false
    )
}

Task {
    do {
        let stats = try await fetchStats(owner: "rabem12", repo: "Barony-MacOS", pat: nil)
        print("Success:", stats)
    } catch {
        print("Error:", error)
    }
    exit(0)
}
RunLoop.main.run()
