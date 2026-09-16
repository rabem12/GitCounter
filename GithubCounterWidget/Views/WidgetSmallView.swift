import SwiftUI
import WidgetKit

@available(macOS 14.0, *)
struct WidgetSmallView: View {
    let stats: RepoStats
    let metric: WidgetDisplayMetric
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                WidgetIconView(size: 16)
                Text(stats.repo)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
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
            }
            
            Spacer(minLength: 0)
            
            switch metric {
            case .downloads:
                Text(stats.formattedTotalDownloads)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text("Total Downloads")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                if let delta = stats.formattedDeltaToday {
                    Text("\(delta) today")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
            case .clones:
                Text("\(stats.totalClones)")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text("Total Clones")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(stats.uniqueCloners) unique")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
            case .views:
                Text("\(stats.totalViews)")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text("Total Views")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(stats.uniqueVisitors) unique")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.purple)
            }
            
            Spacer(minLength: 0)
            
            HStack(spacing: 4) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.blue)
                Text(stats.latestReleaseVersion)
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(4)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(URL(string: "githubcounter://trends?owner=\(stats.owner)&repo=\(stats.repo)"))
    }
}
