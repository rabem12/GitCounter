//
//  GithubCounterWidget.swift
//  GitCounter
//
//  Copyright © 2026 Black Pinion LLC. All rights reserved.
//

import WidgetKit
import SwiftUI
import OSLog

let widgetLogger = Logger(subsystem: "io.githubcounter.GithubCounterApp", category: "WidgetProvider")

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let dummyStats = RepoStats(
            owner: "apple",
            repo: "swift",
            totalDownloads: 1250000,
            latestReleaseVersion: "v5.9",
            latestReleaseDownloads: 45000,
            lastRefreshed: Date(),
            isCached: false
        )
        return SimpleEntry(date: Date(), configuration: RepositoryConfigIntent(), stats: dummyStats, errorMessage: nil, isSetupRequired: false, history: [])
    }
    
    func snapshot(for configuration: RepositoryConfigIntent, in context: Context) async -> SimpleEntry {
        widgetLogger.info("Snapshot requested. Metric: \(configuration.displayMetric.rawValue)")
        let stats = RepoStats(
            owner: "apple",
            repo: "swift",
            totalDownloads: 1250000,
            latestReleaseVersion: "v5.9",
            latestReleaseDownloads: 45000,
            lastRefreshed: Date(),
            isCached: false
        )
        return SimpleEntry(date: Date(), configuration: configuration, stats: stats, errorMessage: nil, isSetupRequired: false, history: [])
    }
    
    func timeline(for configuration: RepositoryConfigIntent, in context: Context) async -> Timeline<SimpleEntry> {
        widgetLogger.info("Timeline requested. Metric: \(configuration.displayMetric.rawValue), Owner: \(configuration.owner), Repo: \(configuration.repo)")
        let owner = configuration.owner.trimmingCharacters(in: .whitespacesAndNewlines)
        let repo = configuration.repo.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If not configured, show setup state
        if owner.isEmpty || repo.isEmpty {
            let entry = SimpleEntry(date: Date(), configuration: configuration, stats: nil, errorMessage: nil, isSetupRequired: true, history: [])
            return Timeline(entries: [entry], policy: .never)
        }
        
        let pat = SecretsManager.shared.getPAT()
        
        var stats: RepoStats?
        var errorMessage: String?
        var isFatalError = false
        var isRateLimitError = false
        
        do {
            let fetchedStats = try await GitHubAPIService.shared.fetchStats(owner: owner, repo: repo, pat: pat)
            CacheManager.shared.save(fetchedStats)
            HistoryManager.shared.recordSnapshot(owner: owner, repo: repo, stats: fetchedStats)
            stats = fetchedStats
        } catch let apiError as GitHubAPIError {
            errorMessage = apiError.localizedDescription
            switch apiError {
            case .repoNotFound, .invalidURL:
                isFatalError = true
            case .rateLimited:
                isRateLimitError = true
            default:
                break
            }
            // Fallback to cache if available
            stats = CacheManager.shared.getCachedStats(owner: owner, repo: repo)
        } catch {
            errorMessage = error.localizedDescription
            // Fallback to cache if available
            stats = CacheManager.shared.getCachedStats(owner: owner, repo: repo)
        }
        
        if let s = stats {
            let deltas = HistoryManager.shared.calculateDeltas(owner: s.owner, repo: s.repo, currentDownloads: s.totalDownloads, currentClones: s.totalClones, currentViews: s.totalViews)
            stats = RepoStats(
                owner: s.owner,
                repo: s.repo,
                totalDownloads: s.totalDownloads,
                latestReleaseVersion: s.latestReleaseVersion,
                latestReleaseDownloads: s.latestReleaseDownloads,
                lastRefreshed: s.lastRefreshed,
                isCached: s.isCached,
                totalClones: s.totalClones,
                uniqueCloners: s.uniqueCloners,
                totalViews: s.totalViews,
                uniqueVisitors: s.uniqueVisitors,
                downloadsToday: deltas.downloadsToday,
                downloadsThisWeek: deltas.downloadsThisWeek,
                clonesToday: deltas.clonesToday,
                clonesThisWeek: deltas.clonesThisWeek,
                viewsToday: deltas.viewsToday,
                viewsThisWeek: deltas.viewsThisWeek,
                isTrafficAuthorized: s.isTrafficAuthorized
            )
        }
        
        var history: [DownloadSnapshot] = []
        if let s = stats {
            history = HistoryManager.shared.getSnapshots(owner: s.owner, repo: s.repo)
        }
        
        let entry = SimpleEntry(date: Date(), configuration: configuration, stats: stats, errorMessage: errorMessage, isSetupRequired: false, history: history)
        
        if isFatalError && stats == nil {
            return Timeline(entries: [entry], policy: .never)
        }
        
        let refreshMinutes = isRateLimitError ? 60 : 30
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: refreshMinutes, to: Date())!
        
        return Timeline(entries: [entry], policy: .after(nextUpdateDate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: RepositoryConfigIntent
    let stats: RepoStats?
    let errorMessage: String?
    let isSetupRequired: Bool
    let history: [DownloadSnapshot]
}

struct GithubCounterWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            if entry.isSetupRequired {
                WidgetSetupView()
            } else if let stats = entry.stats {
                switch family {
                case .systemSmall:
                    WidgetSmallView(stats: stats, metric: entry.configuration.displayMetric)
                case .systemMedium:
                    WidgetMediumView(stats: stats, metric: entry.configuration.displayMetric)
                case .systemLarge:
                    WidgetLargeView(stats: stats, metric: entry.configuration.displayMetric, history: entry.history)
                default:
                    WidgetSmallView(stats: stats, metric: entry.configuration.displayMetric)
                }
            } else {
                VStack {
                    Text("Failed to load data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if let errorMessage = entry.errorMessage {
                        Text(errorMessage)
                            .font(.caption2)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            Rectangle().fill(.ultraThinMaterial)
        }
        .widgetURL(entry.stats?.deepLinkURL)
    }
}

struct GithubCounterWidget: Widget {
    let kind: String = "GithubCounterWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: RepositoryConfigIntent.self, provider: Provider()) { entry in
            GithubCounterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("GitHub Release Stats")
        .description("Tracks release downloads for a GitHub repository.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
