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
                Text("\(stats.owner)/\(stats.repo)")
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
            
            VStack(alignment: .center, spacing: 6) {
                switch metric {
                case .downloads:
                    Text(stats.formattedTotalDownloads)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
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
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Text("Total Clones")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if stats.isTrafficAuthorized {
                        Text("\(stats.uniqueCloners) unique")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        
                        if let delta = stats.formattedClonesToday {
                            Text("\(delta) today")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("Data Not Public")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                case .views:
                    Text("\(stats.totalViews)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    Text("Total Views")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if stats.isTrafficAuthorized {
                        Text("\(stats.uniqueVisitors) unique")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                            
                        if let delta = stats.formattedViewsToday {
                            Text("\(delta) today")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("Data Not Public")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
            
            Spacer(minLength: 0)
            
            HStack(spacing: 4) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.blue)
                Text(stats.formattedReleaseVersion)
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
