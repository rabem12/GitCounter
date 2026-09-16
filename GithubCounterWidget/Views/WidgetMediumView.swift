import SwiftUI
import WidgetKit

@available(macOS 14.0, *)
struct WidgetMediumView: View {
    let stats: RepoStats
    let metric: WidgetDisplayMetric
    
    var orderedMetrics: [WidgetDisplayMetric] {
        var metrics: [WidgetDisplayMetric] = [.downloads, .clones, .views]
        metrics.removeAll { $0 == metric }
        metrics.insert(metric, at: 0)
        return metrics
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                WidgetIconView(size: 16)
                    
                Text("\(stats.owner)/\(stats.repo)")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Button(intent: RefreshWidgetIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                
                if stats.isCached {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 10))
                }
                
                Text(stats.lastRefreshed, style: .time)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.bottom, 2)
            
            // 3 Columns
            HStack(alignment: .top, spacing: 12) {
                if orderedMetrics.count == 3 {
                    column(for: orderedMetrics[0])
                    Divider()
                    column(for: orderedMetrics[1])
                    Divider()
                    column(for: orderedMetrics[2])
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "githubcounter://trends?owner=\(stats.owner)&repo=\(stats.repo)"))
    }
    
    @ViewBuilder
    func column(for m: WidgetDisplayMetric) -> some View {
        let isSelected = (m == metric)
        
        VStack(alignment: .leading, spacing: 6) {
            // Header with Icon
            HStack(spacing: 2) {
                Image(systemName: metricIcon(for: m))
                Text(metricTitle(for: m))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(isSelected ? .blue : .secondary)
            
            // Value
            let valueText: String = {
                switch m {
                case .downloads: return stats.formattedTotalDownloads
                case .clones: return stats.formattedTotalClones
                case .views: return stats.formattedTotalViews
                }
            }()
            
            Text(valueText)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .primary : .secondary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            // Subtitle
            switch m {
            case .downloads:
                VStack(alignment: .leading, spacing: 2) {
                    Text(stats.latestReleaseVersion)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                    Text("\(stats.formattedLatestDownloads) latest")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            case .clones:
                Text("\(stats.uniqueCloners) unique")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            case .views:
                Text("\(stats.uniqueVisitors) unique")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func metricTitle(for m: WidgetDisplayMetric) -> String {
        switch m {
        case .downloads: return "DOWNLOADS"
        case .clones: return "CLONES"
        case .views: return "VIEWS"
        }
    }
    
    func metricIcon(for m: WidgetDisplayMetric) -> String {
        switch m {
        case .downloads: return "arrow.down.circle.fill"
        case .clones: return "doc.on.doc.fill"
        case .views: return "eye.fill"
        }
    }
}
