import Foundation

struct GitHubTrafficClones: Codable {
    let count: Int
    let uniques: Int
}

struct GitHubTrafficViews: Codable {
    let count: Int
    let uniques: Int
}

enum GitHubAPIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case rateLimited
    case decodingError(Error)
    case invalidResponse
    case repoNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid repository owner or name."
        case .networkError(let error):
            return "Network connection error: \(error.localizedDescription)"
        case .rateLimited:
            return "GitHub API rate limit reached (60 req/hr). Add a Personal Access Token in Edit Widget."
        case .decodingError:
            return "Failed to parse release data from GitHub."
        case .invalidResponse:
            return "Received an unexpected response from GitHub."
        case .repoNotFound:
            return "Repository not found. Please verify the owner and repository name."
        }
    }
}

class GitHubAPIService {
    static let shared = GitHubAPIService()
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = false
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchStats(owner: String, repo: String, pat: String?) async throws -> RepoStats {
        let trimmedOwner = owner.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRepo = repo.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let safeOwner = trimmedOwner.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let safeRepo = trimmedRepo.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              !safeOwner.isEmpty, !safeRepo.isEmpty else {
            throw GitHubAPIError.invalidURL
        }
        
        var totalDownloads = 0
        var latestReleaseVersion = "N/A"
        var latestReleaseDownloads = 0
        var fallbackReleaseVersion: String?
        var fallbackReleaseDownloads = 0
        var page = 1
        let maxPages = 10
        var hasMorePages = true
        var isFirstStableReleaseFound = false
        
        let decoder = JSONDecoder()
        
        while hasMorePages && page <= maxPages {
            let urlString = "https://api.github.com/repos/\(safeOwner)/\(safeRepo)/releases?per_page=100&page=\(page)"
            guard let url = URL(string: urlString) else {
                throw GitHubAPIError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            request.setValue("GithubCounterWidget/1.0", forHTTPHeaderField: "User-Agent")
            
            if let pat = pat?.trimmingCharacters(in: .whitespacesAndNewlines), !pat.isEmpty {
                request.setValue("Bearer \(pat)", forHTTPHeaderField: "Authorization")
            }
            
            let data: Data
            let response: URLResponse
            do {
                (data, response) = try await session.data(for: request)
            } catch {
                throw GitHubAPIError.networkError(error)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GitHubAPIError.invalidResponse
            }
            
            if httpResponse.statusCode == 404 {
                throw GitHubAPIError.repoNotFound
            }
            
            if httpResponse.statusCode == 403 || httpResponse.statusCode == 429 {
                throw GitHubAPIError.rateLimited
            }
            
            guard httpResponse.statusCode == 200 else {
                throw GitHubAPIError.invalidResponse
            }
            
            do {
                let releases = try decoder.decode([GitHubRelease].self, from: data)
                
                if releases.isEmpty {
                    hasMorePages = false
                    break
                }
                
                for release in releases {
                    let releaseDownloads = release.assets.reduce(0) { $0 + $1.downloadCount }
                    totalDownloads += releaseDownloads
                    
                    if !release.draft {
                        if fallbackReleaseVersion == nil {
                            fallbackReleaseVersion = release.tagName
                            fallbackReleaseDownloads = releaseDownloads
                        }
                        
                        if !isFirstStableReleaseFound && !release.prerelease {
                            latestReleaseVersion = release.tagName
                            latestReleaseDownloads = releaseDownloads
                            isFirstStableReleaseFound = true
                        }
                    }
                }
                
                if releases.count < 100 {
                    hasMorePages = false
                } else {
                    page += 1
                }
                
            } catch {
                throw GitHubAPIError.decodingError(error)
            }
        }
        
        // If no stable release was found, fall back to the newest non-draft release
        if !isFirstStableReleaseFound, let fallback = fallbackReleaseVersion {
            latestReleaseVersion = fallback
            latestReleaseDownloads = fallbackReleaseDownloads
        }
        
        var totalClones = 0
        var uniqueCloners = 0
        var totalViews = 0
        var uniqueVisitors = 0
        
        if let pat = pat?.trimmingCharacters(in: .whitespacesAndNewlines), !pat.isEmpty {
            // Fetch Clones
            if let clonesURL = URL(string: "https://api.github.com/repos/\(safeOwner)/\(safeRepo)/traffic/clones") {
                var req = URLRequest(url: clonesURL)
                req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
                req.setValue("GithubCounterWidget/1.0", forHTTPHeaderField: "User-Agent")
                req.setValue("Bearer \(pat)", forHTTPHeaderField: "Authorization")
                
                if let (cData, cRes) = try? await session.data(for: req),
                   let httpRes = cRes as? HTTPURLResponse, httpRes.statusCode == 200,
                   let clonesResponse = try? decoder.decode(GitHubTrafficClones.self, from: cData) {
                    totalClones = clonesResponse.count
                    uniqueCloners = clonesResponse.uniques
                }
            }
            
            // Fetch Views
            if let viewsURL = URL(string: "https://api.github.com/repos/\(safeOwner)/\(safeRepo)/traffic/views") {
                var req = URLRequest(url: viewsURL)
                req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
                req.setValue("GithubCounterWidget/1.0", forHTTPHeaderField: "User-Agent")
                req.setValue("Bearer \(pat)", forHTTPHeaderField: "Authorization")
                
                if let (vData, vRes) = try? await session.data(for: req),
                   let httpRes = vRes as? HTTPURLResponse, httpRes.statusCode == 200,
                   let viewsResponse = try? decoder.decode(GitHubTrafficViews.self, from: vData) {
                    totalViews = viewsResponse.count
                    uniqueVisitors = viewsResponse.uniques
                }
            }
        }
        
        // Fallback: If no traffic data was retrieved (e.g. no PAT or API failed), try fetching from the public CSV
        if totalClones == 0 && totalViews == 0 {
            if let csvURL = URL(string: "https://raw.githubusercontent.com/\(safeOwner)/\(safeRepo)/main/stats/downloads.csv") {
                var req = URLRequest(url: csvURL)
                req.cachePolicy = .reloadIgnoringLocalCacheData
                if let (csvData, csvRes) = try? await URLSession.shared.data(for: req),
                   let httpRes = csvRes as? HTTPURLResponse, httpRes.statusCode == 200,
                   let csvString = String(data: csvData, encoding: .utf8) {
                    
                    let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
                    if lines.count > 1, let lastLine = lines.last {
                        let cols = lastLine.components(separatedBy: ",")
                        // Format: Date,Total Downloads,Latest Release Downloads,Version,Total Clones,Unique Cloners,Total Views,Unique Visitors
                        if cols.count >= 8 {
                            totalClones = Int(cols[4]) ?? 0
                            uniqueCloners = Int(cols[5]) ?? 0
                            totalViews = Int(cols[6]) ?? 0
                            uniqueVisitors = Int(cols[7]) ?? 0
                        }
                    }
                }
            }
        }
        
        let statsToReturn = RepoStats(
            owner: trimmedOwner,
            repo: trimmedRepo,
            totalDownloads: totalDownloads,
            latestReleaseVersion: latestReleaseVersion,
            latestReleaseDownloads: latestReleaseDownloads,
            lastRefreshed: Date(),
            isCached: false,
            totalClones: totalClones,
            uniqueCloners: uniqueCloners,
            totalViews: totalViews,
            uniqueVisitors: uniqueVisitors
        )
        
        let debugString = "Fetched \(trimmedOwner)/\(trimmedRepo) -> Clones: \(totalClones), Views: \(totalViews)\n"
        if let data = debugString.data(using: .utf8),
           let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.io.githubcounter") {
            let url = containerURL.appendingPathComponent("widget_debug.txt")
            if let fileHandle = try? FileHandle(forWritingTo: url) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                try? data.write(to: url)
            }
        }
        
        return statsToReturn

    }
}
