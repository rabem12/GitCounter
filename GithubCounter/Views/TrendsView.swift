import SwiftUI
import Charts
import WidgetKit

struct TrendsView: View {
    @ObservedObject private var sharedData = SharedPreferences.shared
    
    @State private var snapshots: [DownloadSnapshot] = []
    @State private var showCopiedMessage = false
    enum ConnectionTestStatus: Equatable {
        case idle
        case testing
        case success
        case failure(reason: String)
    }
    
    @State private var showClearConfirmation = false
    @State private var showClearPATConfirmation = false
    
    @State private var owner: String = ""
    @State private var repo: String = ""
    @State private var pat: String = ""
    @State private var isFetching: Bool = false
    @State private var testStatus: ConnectionTestStatus = .idle
    @State private var testStatusResetTask: Task<Void, Never>? = nil
    @State private var currentStats: RepoStats?
    @State private var fetchTask: Task<Void, Never>? = nil
    enum ChartViewTab: String, CaseIterable {
        case cumulative = "Cumulative Growth"
        case velocity = "Daily Velocity"
        case history = "History Log"
    }
    
    @State private var selectedMetric: WidgetDisplayMetric = .downloads
    @State private var selectedChartTab: ChartViewTab = .cumulative
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            
            inputSection
            
            if let stats = currentStats {
                publicMetricsRow(stats: stats)
            }
            
            if snapshots.isEmpty {
                emptyStateView
            } else {
                Picker("Display Metric", selection: $selectedMetric) {
                    Text("Downloads").tag(WidgetDisplayMetric.downloads)
                    Text("Clones").tag(WidgetDisplayMetric.clones)
                    Text("Views").tag(WidgetDisplayMetric.views)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 340)
                
                metricsGrid
                
                Picker("Chart View", selection: $selectedChartTab) {
                    ForEach(ChartViewTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 380)
                .padding(.top, 4)
                
                Group {
                    switch selectedChartTab {
                    case .cumulative:
                        cumulativeChart
                    case .velocity:
                        velocityChart
                    case .history:
                        historyTable
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .animation(.easeInOut, value: currentStats)
        .onAppear {
            if owner.isEmpty {
                owner = sharedData.savedOwner
            }
            if repo.isEmpty {
                repo = sharedData.savedRepo
            }
            if pat.isEmpty {
                pat = SecretsManager.shared.getPAT()
            }
            loadSnapshots()
            if !owner.isEmpty && !repo.isEmpty {
                fetchStats()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveDeepLink)) { _ in
            owner = sharedData.savedOwner
            repo = sharedData.savedRepo
            loadSnapshots()
            if !owner.isEmpty && !repo.isEmpty {
                fetchStats()
            }
        }
        .onChange(of: owner) { _, _ in resetTestStatus() }
        .onChange(of: repo) { _, _ in resetTestStatus() }
        .onChange(of: pat) { _, _ in resetTestStatus() }
    }
    
    private var inputSection: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Owner (e.g., apple)", text: $owner)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Repository (e.g., swift)", text: $repo)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Global PAT (Optional)", text: $pat)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack(spacing: 16) {
                Button(action: { fetchStats(isManualTest: true) }) {
                    HStack(spacing: 6) {
                        switch testStatus {
                        case .idle:
                            Text("Test Connection")
                        case .testing:
                            ProgressView()
                                .scaleEffect(0.5)
                                .frame(width: 14, height: 14)
                            Text("Testing...")
                        case .success:
                            Image(systemName: "checkmark.circle.fill")
                            Text("Connected")
                        case .failure:
                            Image(systemName: "xmark.circle.fill")
                            Text("Failed")
                        }
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(testButtonBackgroundColor)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .help(testButtonTooltip)
                .disabled(owner.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || repo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || testStatus == .testing)
                
                if !pat.isEmpty {
                    Button("Clear PAT") {
                        showClearPATConfirmation = true
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .alert("Clear Personal Access Token?", isPresented: $showClearPATConfirmation) {
                        Button("Clear PAT", role: .destructive) {
                            pat = ""
                            SecretsManager.shared.clearPAT()
                            WidgetCenter.shared.reloadAllTimelines()
                            resetTestStatus()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure you want to remove your saved Personal Access Token? Any desktop widgets or traffic metrics requiring authentication will stop updating.")
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private func publicMetricsRow(stats: RepoStats) -> some View {
        HStack(spacing: 24) {
            Label("\(formatNumber(stats.stars)) Stars", systemImage: "star.fill")
                .foregroundColor(.yellow)
            Label("\(formatNumber(stats.forks)) Forks", systemImage: "tuningfork")
                .foregroundColor(.blue)
            Label("\(formatNumber(stats.openIssues)) Open Issues", systemImage: "ladybug.fill")
                .foregroundColor(.red)
        }
        .font(.headline)
        .padding(.vertical, 8)
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
                        sharedData.savedOwner = ""
                        sharedData.savedRepo = ""
                        owner = ""
                        repo = ""
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
    
    private var selectedMetricTitle: String {
        switch selectedMetric {
        case .downloads: return "Downloads"
        case .clones: return "Clones"
        case .views: return "Views"
        }
    }
    
    private var metricsGrid: some View {
        HStack(spacing: 16) {
            let total = snapshots.last.map { chartYValue(for: $0) } ?? 0
            let last = snapshots.last
            let deltas = HistoryManager.shared.calculateDeltas(
                owner: sharedData.savedOwner,
                repo: sharedData.savedRepo,
                currentDownloads: last?.totalDownloads ?? 0,
                currentClones: last?.totalClones ?? 0,
                currentViews: last?.totalViews ?? 0
            )
            
            let deltaToday: Int? = {
                switch selectedMetric {
                case .downloads: return deltas.downloadsToday
                case .clones: return deltas.clonesToday
                case .views: return deltas.viewsToday
                }
            }()
            
            let deltaWeek: Int? = {
                switch selectedMetric {
                case .downloads: return deltas.downloadsThisWeek
                case .clones: return deltas.clonesThisWeek
                case .views: return deltas.viewsThisWeek
                }
            }()
            
            MetricCard(title: "Total \(selectedMetricTitle)", value: formatNumber(total), color: chartColor())
            
            if let today = deltaToday {
                MetricCard(title: "Gained Today", value: "+\(formatNumber(today))", color: .green)
            } else {
                MetricCard(title: "Gained Today", value: "-", color: .secondary)
            }
            
            if let week = deltaWeek {
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
                y: .value(selectedMetricTitle, yValue)
            )
            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [chartColor().opacity(0.5), chartColor().opacity(0.1)]), startPoint: .top, endPoint: .bottom))
            
            LineMark(
                x: .value("Date", snapshot.date),
                y: .value(selectedMetricTitle, yValue)
            )
            .foregroundStyle(chartColor())
            .symbol(Circle())
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                if let count = value.as(Int.self) {
                    AxisValueLabel {
                        Text(formatNumber(count))
                    }
                }
            }
        }
        .chartXAxisLabel("Date")
        .chartYAxisLabel("Total \(selectedMetricTitle)")
        .padding()
    }
    
    private var velocityChart: some View {
        let velocityData = calculateVelocity()
        return Chart(velocityData, id: \.date) { item in
            BarMark(
                x: .value("Date", item.date),
                y: .value("\(selectedMetricTitle) Gained", item.gained)
            )
            .foregroundStyle(chartColor())
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: .dateTime.month().day())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                if let count = value.as(Int.self) {
                    AxisValueLabel {
                        Text(formatNumber(count))
                    }
                }
            }
        }
        .chartXAxisLabel("Date")
        .chartYAxisLabel("\(selectedMetricTitle) Gained")
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
            TableColumn("Downloads") { snapshot in
                Text("\(snapshot.totalDownloads)")
            }
            TableColumn("Clones") { snapshot in
                Text(snapshot.totalClones.map { "\($0)" } ?? "-")
            }
            TableColumn("Views") { snapshot in
                Text(snapshot.totalViews.map { "\($0)" } ?? "-")
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
        let gained = chartYValue(for: last) - chartYValue(for: first)
        return max(0, gained / days)
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
        case .downloads:
            return snapshot.totalDownloads
        case .clones:
            return snapshot.totalClones ?? 0
        case .views:
            return snapshot.totalViews ?? 0
        }
    }
    
    private func chartColor() -> Color {
        switch selectedMetric {
        case .downloads:
            return .purple
        case .clones:
            return .blue
        case .views:
            return .green
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
    
    private var testButtonBackgroundColor: Color {
        switch testStatus {
        case .idle, .testing:
            return .blue
        case .success:
            return .green
        case .failure:
            return .red
        }
    }
    
    private var testButtonTooltip: String {
        switch testStatus {
        case .idle:
            return "Test connection to repository"
        case .testing:
            return "Connecting to GitHub..."
        case .success:
            return "Connection successful! Data refreshed."
        case .failure(let reason):
            return "Connection failed: \(reason)"
        }
    }
    
    private func resetTestStatus() {
        if testStatus != .idle && testStatus != .testing {
            testStatusResetTask?.cancel()
            withAnimation {
                testStatus = .idle
            }
        }
    }
    
    private func fetchStats(isManualTest: Bool = false) {
        let cleanOwner = owner.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanRepo = repo.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPat = pat.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanOwner.isEmpty && !cleanRepo.isEmpty else { return }
        
        // Cancel any active/in-flight fetch immediately to avoid race conditions
        fetchTask?.cancel()
        testStatusResetTask?.cancel()
        
        isFetching = true
        if isManualTest {
            withAnimation {
                testStatus = .testing
            }
        }
        currentStats = nil
        
        fetchTask = Task {
            do {
                let fetchedStats = try await GitHubAPIService.shared.fetchStats(owner: cleanOwner, repo: cleanRepo, pat: cleanPat)
                
                await MainActor.run {
                    // Discard results if task was cancelled or if user/deep link switched repos
                    guard !Task.isCancelled else { return }
                    guard self.owner.trimmingCharacters(in: .whitespacesAndNewlines) == cleanOwner &&
                          self.repo.trimmingCharacters(in: .whitespacesAndNewlines) == cleanRepo else { return }
                    
                    self.currentStats = fetchedStats
                    self.isFetching = false
                    if isManualTest {
                        withAnimation {
                            self.testStatus = .success
                        }
                        // Auto-reset button to idle after 3 seconds
                        self.testStatusResetTask = Task {
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            guard !Task.isCancelled else { return }
                            await MainActor.run {
                                withAnimation {
                                    self.testStatus = .idle
                                }
                            }
                        }
                    }
                    sharedData.savedOwner = cleanOwner
                    sharedData.savedRepo = cleanRepo
                    SecretsManager.shared.savePAT(cleanPat)
                    WidgetCenter.shared.reloadAllTimelines()
                    loadSnapshots()
                }
            } catch {
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    self.isFetching = false
                    if isManualTest {
                        withAnimation {
                            self.testStatus = .failure(reason: error.localizedDescription)
                        }
                        // Auto-reset button to idle after 5 seconds
                        self.testStatusResetTask = Task {
                            try? await Task.sleep(nanoseconds: 5_000_000_000)
                            guard !Task.isCancelled else { return }
                            await MainActor.run {
                                withAnimation {
                                    self.testStatus = .idle
                                }
                            }
                        }
                    }
                    print("Error fetching stats: \(error)")
                }
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
