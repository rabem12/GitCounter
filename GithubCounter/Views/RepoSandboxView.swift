import SwiftUI
import WidgetKit

struct RepoSandboxView: View {
    @State private var owner: String = ""
    @State private var repo: String = ""
    @State private var pat: String = ""
    
    @State private var stats: RepoStats?
    @State private var isFetching: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section(
                    header: Text("Repository Details").font(.headline),
                    footer: Text("The Personal Access Token is saved globally. All of your desktop widgets will automatically use this token to refresh their data.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                ) {
                    TextField("Owner (e.g., apple)", text: $owner)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Repository (e.g., swift)", text: $repo)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Global Personal Access Token (Optional)", text: $pat)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.bottom)
                
                HStack(spacing: 16) {
                    Button(action: fetchStats) {
                        if isFetching {
                            ProgressView()
                                .scaleEffect(0.5)
                                .frame(width: 100)
                        } else {
                            Text("Test Connection")
                                .frame(width: 100)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(owner.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || repo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isFetching)
                    
                    if !pat.isEmpty {
                        Button("Clear PAT") {
                            pat = ""
                            SecretsManager.shared.clearPAT()
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            }
            .padding()
            .frame(maxWidth: 400)
            
            Divider()
            
            if let error = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let stats = stats {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.largeTitle)
                    
                    Text("Connection Successful!")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        statRow(title: "Total Downloads", value: stats.formattedTotalDownloads)
                        statRow(title: "Latest Release", value: stats.latestReleaseVersion)
                        statRow(title: "Latest Downloads", value: stats.formattedLatestDownloads)
                        statRow(title: "Last Refreshed", value: stats.lastRefreshed.formatted(date: .omitted, time: .shortened))
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary.opacity(0.5))
                        .padding(.bottom, 8)
                    Text("Enter repository details and test the connection.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if owner.isEmpty {
                owner = SharedPreferences.shared.savedOwner
            }
            if repo.isEmpty {
                repo = SharedPreferences.shared.savedRepo
            }
            if pat.isEmpty {
                pat = SecretsManager.shared.getPAT()
            }
        }
    }
    
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .frame(width: 250)
    }
    
    private func fetchStats() {
        let cleanOwner = owner.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanRepo = repo.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPat = pat.trimmingCharacters(in: .whitespacesAndNewlines)
        
        isFetching = true
        errorMessage = nil
        stats = nil
        
        Task {
            do {
                let fetchedStats = try await GitHubAPIService.shared.fetchStats(owner: cleanOwner, repo: cleanRepo, pat: cleanPat)
                await MainActor.run {
                    self.stats = fetchedStats
                    self.isFetching = false
                    SharedPreferences.shared.savedOwner = cleanOwner
                    SharedPreferences.shared.savedRepo = cleanRepo
                    SecretsManager.shared.savePAT(cleanPat)
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isFetching = false
                }
            }
        }
    }
}
