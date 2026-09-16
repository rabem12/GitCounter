import SwiftUI
import Charts

struct TrendsView: View {
    @ObservedObject private var sharedData = SharedPreferences.shared
    
    @State private var snapshots: [DownloadSnapshot] = []
    @State private var showCopiedMessage = false
    @State private var showClearConfirmation = false
    @State private var selectedMetric: ChartMetric = .downloads
    
    enum ChartMetric: String, CaseIterable, Identifiable {
        case downloads = "Downloads"
        case clones = "Clones"
        case views = "Views"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            
            if snapshots.isEmpty {
                emptyStateView
            } else {
                metricsGrid
                
                TabView {
                    cumulativeChart
                        .tabItem { Text("Cumulative Growth") }
                    
                    velocityChart
                        .tabItem { Text("Daily Velocity") }
                    
                    historyTable
                        .tabItem { Text("History Log") }
                }
                .padding(.top, 10)
            }
        }
        .padding()
        .onAppear(perform: loadSnapshots)
        .onChange(of: sharedData.savedOwner) { _ in loadSnapshots() }
        .onChange(of: sharedData.savedRepo) { _ in loadSnapshots() }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Trends & History")
                    .font(.title)
                    .fontWeight(.bold)
                
                if sharedData.savedOwner.isEmpty || sharedData.savedRepo.isEmpty {
                    Text("No repositories found")
                        .foregroundColor(.secondary)
                } else {
                    Text("\(sharedData.savedOwner)/\(sharedData.savedRepo)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            
            if !snapshots.isEmpty {
                Picker("Metric", selection: $selectedMetric) {
                    ForEach(ChartMetric.allCases) { metric in
                        Text(metric.rawValue).tag(metric)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 300)
            }
            
            Spacer()
            
            if !sharedData.savedOwner.isEmpty && !sharedData.savedRepo.isEmpty {
                Button(action: { showClearConfirmation = true }) {
                    Label("Clear Data", systemImage: "trash")
                        .foregroundColor(.red)
                }
                .alert("Delete Repository Data?", isPresented: $showClearConfirmation) {
                    Button("Delete", role: .destructive) {
                        HistoryManager.shared.clearHistory(owner: sharedData.savedOwner, repo: sharedData.savedRepo)
                        snapshots = []
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("This will permanently delete the downloaded history for \(sharedData.savedOwner)/\(sharedData.savedRepo).")
                }
            }

            if !sharedData.savedOwner.isEmpty && !sharedData.savedRepo.isEmpty {
                Button(action: fetchCloudCSV) {
                    Label("Sync Cloud", systemImage: "arrow.triangle.2.circlepath.circle")
                }
                .help("Fetches the latest stats/downloads.csv from the main branch of the repository.")
            }

            Button(action: copyGitHubAction) {
                if showCopiedMessage {
                    Label("Copied to Clipboard!", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Label("Setup Cloud Logger", systemImage: "cloud.fill")
                }
            }
            .help("Copies the GitHub Action script to your clipboard to enable 24/7 background logging.")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No Historical Data Yet")
                .font(.headline)
            Text("Snapshots will be recorded automatically when the widget or app refreshes.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
    private var metricsGrid: some View {
        HStack(spacing: 16) {
            let total = snapshots.last?.totalDownloads ?? 0
            MetricCard(title: "Total All-Time", value: formatNumber(total), color: .purple)
            
            let deltas = HistoryManager.shared.calculateDeltas(owner: sharedData.savedOwner, repo: sharedData.savedRepo, currentTotal: total)
            
            if let today = deltas.today {
                MetricCard(title: "Gained Today", value: "+\(formatNumber(today))", color: .green)
            } else {
                MetricCard(title: "Gained Today", value: "-", color: .secondary)
            }
            
            if let week = deltas.thisWeek {
                MetricCard(title: "Gained This Week", value: "+\(formatNumber(week))", color: .blue)
            } else {
                MetricCard(title: "Gained This Week", value: "-", color: .secondary)
            }
            
            let avg = calculateDailyAverage()
            MetricCard(title: "Daily Average", value: "~\(formatNumber(avg))/day", color: .orange)
        }
    }
    
    private var cumulativeChart: some View {
        Chart(snapshots) { snapshot in
            let yValue = chartYValue(for: snapshot)
            AreaMark(
                x: .value("Date", snapshot.date),
                y: .value(selectedMetric.rawValue, yValue)
            )
            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [chartColor().opacity(0.5), chartColor().opacity(0.1)]), startPoint: .top, endPoint: .bottom))
            
            LineMark(
                x: .value("Date", snapshot.date),
                y: .value(selectedMetric.rawValue, yValue)
            )
            .foregroundStyle(chartColor())
            .symbol(Circle())
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day))
        }
        .padding()
    }
    
    private var velocityChart: some View {
        let velocityData = calculateVelocity()
        return Chart(velocityData, id: \.date) { item in
            BarMark(
                x: .value("Date", item.date),
                y: .value("\(selectedMetric.rawValue) Gained", item.gained)
            )
            .foregroundStyle(chartColor())
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day))
        }
        .padding()
    }
    
    private var historyTable: some View {
        Table(snapshots.reversed()) {
            TableColumn("Date") { snapshot in
                Text(snapshot.date, style: .date)
            }
            TableColumn("Time") { snapshot in
                Text(snapshot.date, style: .time)
            }
            TableColumn("Version", value: \.version)
            TableColumn("Total") { snapshot in
                Text("\(snapshot.totalDownloads)")
            }
        }
    }
    
    private func loadSnapshots() {
        if sharedData.savedOwner.isEmpty || sharedData.savedRepo.isEmpty {
            let available = HistoryManager.shared.getAvailableRepos()
            if let first = available.first {
                sharedData.savedOwner = first.owner
                sharedData.savedRepo = first.repo
            }
        }
        
        
        if !sharedData.savedOwner.isEmpty && !sharedData.savedRepo.isEmpty {
            snapshots = HistoryManager.shared.getSnapshots(owner: sharedData.savedOwner, repo: sharedData.savedRepo)
        } else {
            snapshots = []
        }
    }
    
    private func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 {
            let val = Double(num) / 1_000_000.0
            return val.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0fM", val) : String(format: "%.1fM", val)
        } else if num >= 1_000 {
            let val = Double(num) / 1_000.0
            return val.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0fK", val) : String(format: "%.1fK", val)
        } else {
            return "\(num)"
        }
    }
    
    private func calculateDailyAverage() -> Int {
        guard let first = snapshots.first, let last = snapshots.last, snapshots.count > 1 else { return 0 }
        let days = max(1, Calendar.current.dateComponents([.day], from: first.date, to: last.date).day ?? 1)
        let gained = last.totalDownloads - first.totalDownloads
        return gained / days
    }
    
    private struct VelocityItem {
        let date: Date
        let gained: Int
    }
    
    private func calculateVelocity() -> [VelocityItem] {
        var results: [VelocityItem] = []
        guard snapshots.count > 1 else { return results }
        
        for i in 1..<snapshots.count {
            let prev = snapshots[i-1]
            let curr = snapshots[i]
            let prevY = chartYValue(for: prev)
            let currY = chartYValue(for: curr)
            let gained = max(0, currY - prevY)
            results.append(VelocityItem(date: curr.date, gained: gained))
        }
        return results
    }
    
    private func chartYValue(for snapshot: DownloadSnapshot) -> Int {
        switch selectedMetric {
        case .downloads: return snapshot.totalDownloads
        case .clones: return snapshot.totalClones ?? 0
        case .views: return snapshot.totalViews ?? 0
        }
    }
    
    private func chartColor() -> Color {
        switch selectedMetric {
        case .downloads: return .purple
        case .clones: return .orange
        case .views: return .green
        }
    }
    
    private func exportCSV() {
        guard let url = HistoryManager.shared.exportCSV(owner: sharedData.savedOwner, repo: sharedData.savedRepo) else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
    
    private func fetchCloudCSV() {
        guard !sharedData.savedOwner.isEmpty && !sharedData.savedRepo.isEmpty else { return }
        
        let urlStr = "https://raw.githubusercontent.com/\(sharedData.savedOwner)/\(sharedData.savedRepo)/main/stats/downloads.csv"
        guard let url = URL(string: urlStr) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let csvString = String(data: data, encoding: .utf8) {
                    await MainActor.run {
                        HistoryManager.shared.ingestCSV(csvString: csvString, owner: sharedData.savedOwner, repo: sharedData.savedRepo)
                        loadSnapshots()
                    }
                }
            } catch {
                print("Failed to fetch cloud CSV: \(error)")
            }
        }
    }
    
    private func copyGitHubAction() {
        let workflow = """
        name: Log Release Downloads 24/7

        on:
          schedule:
            - cron: '0 0 * * *'
          workflow_dispatch:

        permissions:
          contents: write

        jobs:
          log-downloads:
            runs-on: ubuntu-latest
            steps:
              - name: Check out repository
                uses: actions/checkout@v4
                with:
                  fetch-depth: 0

              - name: Fetch and Record Download Counts
                env:
                  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
                  TRAFFIC_PAT: ${{ secrets.TRAFFIC_PAT }}
                run: |
                  mkdir -p stats
                  CSV_FILE="stats/downloads.csv"

                  if [ ! -f "$CSV_FILE" ]; then
                    echo "Date,Total Downloads,Latest Release Downloads,Version,Total Clones,Unique Cloners,Total Views,Unique Visitors" > "$CSV_FILE"
                  else
                    sed -i '' '1s/.*/Date,Total Downloads,Latest Release Downloads,Version,Total Clones,Unique Cloners,Total Views,Unique Visitors/' "$CSV_FILE" 2>/dev/null || sed -i '1s/.*/Date,Total Downloads,Latest Release Downloads,Version,Total Clones,Unique Cloners,Total Views,Unique Visitors/' "$CSV_FILE"
                  fi

                  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
                  
                  RESPONSE=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \\
                    -H "Accept: application/vnd.github+json" \\
                    "https://api.github.com/repos/${{ github.repository }}/releases?per_page=100")

                  TOTAL=$(echo "$RESPONSE" | jq '[.[].assets[].download_count] | add // 0')
                  LATEST_TAG=$(echo "$RESPONSE" | jq -r '.[0].tag_name // "none"')
                  LATEST_DOWNLOADS=$(echo "$RESPONSE" | jq '[.[0].assets[].download_count] | add // 0')

                  CLONES_COUNT=0
                  CLONES_UNIQUES=0
                  VIEWS_COUNT=0
                  VIEWS_UNIQUES=0

                  if [ -n "$TRAFFIC_PAT" ]; then
                    CLONES_RESP=$(curl -s -H "Authorization: Bearer $TRAFFIC_PAT" \\
                      -H "Accept: application/vnd.github+json" \\
                      "https://api.github.com/repos/${{ github.repository }}/traffic/clones")
                    CLONES_COUNT=$(echo "$CLONES_RESP" | jq -r '.count // 0')
                    CLONES_UNIQUES=$(echo "$CLONES_RESP" | jq -r '.uniques // 0')

                    VIEWS_RESP=$(curl -s -H "Authorization: Bearer $TRAFFIC_PAT" \\
                      -H "Accept: application/vnd.github+json" \\
                      "https://api.github.com/repos/${{ github.repository }}/traffic/views")
                    VIEWS_COUNT=$(echo "$VIEWS_RESP" | jq -r '.count // 0')
                    VIEWS_UNIQUES=$(echo "$VIEWS_RESP" | jq -r '.uniques // 0')
                  fi

                  echo "$TIMESTAMP,$TOTAL,$LATEST_DOWNLOADS,$LATEST_TAG,$CLONES_COUNT,$CLONES_UNIQUES,$VIEWS_COUNT,$VIEWS_UNIQUES" >> "$CSV_FILE"

              - name: Commit and Push
                run: |
                  git config --global user.name "github-actions[bot]"
                  git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
                  git add stats/downloads.csv
                  if ! git diff --staged --quiet; then
                    git commit -m "chore(stats): update download metrics [skip ci]"
                    git pull --rebase origin ${{ github.event.repository.default_branch }}
                    git push origin HEAD:${{ github.event.repository.default_branch }}
                  fi
        """
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(workflow, forType: .string)
        
        withAnimation {
            showCopiedMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopiedMessage = false
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
    }
}
