import SwiftUI
import WidgetKit
import Charts

@available(macOS 14.0, *)
struct WidgetLargeView: View {
    let stats: RepoStats
    let metric: WidgetDisplayMetric
    let history: [DownloadSnapshot]
    
    init(stats: RepoStats, metric: WidgetDisplayMetric, history: [DownloadSnapshot]) {
        self.stats = stats
        self.metric = metric
        self.history = history
    }
    
    var orderedMetrics: [WidgetDisplayMetric] {
        var metrics: [WidgetDisplayMetric] = [.downloads, .clones, .views]
        metrics.removeAll { $0 == metric }
        metrics.insert(metric, at: 0)
        return metrics
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack {
                HStack(spacing: 8) {
                    WidgetIconView(size: 20)
                        
                    Text("\(stats.owner)/\(stats.repo)")
                        .font(.headline)
                        .bold()
                }
                Spacer()
                
                // Interactive Refresh Button
                Button(intent: RefreshWidgetIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary.opacity(0.8))
                        .padding(8)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            
            // 3 Columns (Selected metric is first)
            HStack(alignment: .top, spacing: 12) {
                if orderedMetrics.count == 3 {
                    column(for: orderedMetrics[0])
                    Divider()
                    column(for: orderedMetrics[1])
                    Divider()
                    column(for: orderedMetrics[2])
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 4)
            
            // The Chart
            if history.isEmpty {
                Spacer()
                Text("Not enough historical data to display a chart.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    // Chart Identity Label
                    HStack(spacing: 4) {
                        Image(systemName: metricIcon(for: metric))
                        Text("\(metricTitle(for: metric)) TREND")
                        
                        Spacer()
                        
                        Text("Updated \(stats.lastRefreshed, format: .dateTime.hour().minute())")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.top, 4)
                    
                    let axisDates: [Date] = {
                        guard let first = history.first?.date, let last = history.last?.date else { return [] }
                        let calendar = Calendar.current
                        let firstDay = calendar.component(.day, from: first)
                        let lastDay = calendar.component(.day, from: last)
                        
                        if firstDay == lastDay {
                            return [first]
                        }
                        
                        var dates = [first]
                        
                        var uniqueDays = Set<Int>()
                        for snapshot in history {
                            uniqueDays.insert(calendar.component(.day, from: snapshot.date))
                        }
                        
                        if uniqueDays.count >= 3 {
                            let midTime = (first.timeIntervalSince1970 + last.timeIntervalSince1970) / 2
                            var bestMid: Date? = nil
                            var minDiff = Double.greatestFiniteMagnitude
                            for snapshot in history {
                                let day = calendar.component(.day, from: snapshot.date)
                                if day != firstDay && day != lastDay {
                                    let diff = abs(snapshot.date.timeIntervalSince1970 - midTime)
                                    if diff < minDiff {
                                        minDiff = diff
                                        bestMid = snapshot.date
                                    }
                                }
                            }
                            if let bestMid = bestMid {
                                dates.append(bestMid)
                            }
                        }
                        
                        dates.append(last)
                        return dates
                    }()
                    
                    Chart {
                        ForEach(history, id: \.date) { snapshot in
                            let valueToPlot: Int = {
                                switch metric {
                                case .downloads: return snapshot.totalDownloads
                                case .clones: return snapshot.totalClones ?? 0
                                case .views: return snapshot.totalViews ?? 0
                                }
                            }()
                            
                            // Gradient Fill Area
                            AreaMark(
                                x: .value("Date", snapshot.date),
                                y: .value("Count", valueToPlot)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.5), .purple.opacity(0.1)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // Solid Line
                            LineMark(
                                x: .value("Date", snapshot.date),
                                y: .value("Count", valueToPlot)
                            )
                            .foregroundStyle(Color.blue)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: axisDates) { value in
                            AxisGridLine()
                            AxisTick()
                            if let date = value.as(Date.self) {
                                let isFirst = date == axisDates.first
                                let isLast = date == axisDates.last
                                let alignment: UnitPoint = isFirst ? .topLeading : (isLast ? .topTrailing : .top)
                                
                                AxisValueLabel(anchor: alignment) {
                                    Text(date, format: .dateTime.month().day())
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
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
