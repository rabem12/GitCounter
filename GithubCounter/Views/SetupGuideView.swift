import SwiftUI

struct SetupGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("GitCounter Manual")
                    .font(.largeTitle)
                    .bold()
                
                widgetSection
                Divider()
                dashboardSection
                Divider()
                launchpadSection
                Divider()
                diagnosticsSection
                Divider()
                cloudLoggingSection
                
                Spacer()
                
                Divider()
                
                Text("Git and the Git logo are trademarks of Software Freedom Conservancy, Inc. GitCounter is an independent tool and is not affiliated with Software Freedom Conservancy or GitHub, Inc.")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }
            .padding(32)
        }
    }
    
    // MARK: - 1. Widget Functionality
    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("1. Widget Functionality")
                .font(.title2)
                .bold()
            
            Text("Adding and Editing the Widget")
                .font(.title3)
                .bold()
                .padding(.top, 4)
            
            Text("Open the  macOS Notification Center, click ‘Edit Widgets,’ search for ‘GitCounter,’ and drag the widget to your desktop. Right-click the widget and select ‘Edit “GitHub Release Stats”’ to configure the owner, repository, and primary metric.")
            
            // 3 desktop widgets running side-by-side
            HStack(alignment: .center, spacing: 16) {
                Image("guide_widget_large")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                
                Image("guide_widget_medium")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                
                Image("guide_widget_small")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
            }
            .padding(.vertical, 6)
            
            Text("When Right clicking on any of the widgets, select Edit “GitHub Release Stats” to set the display repository for the widget.")
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("• **Owner:** The official Repository owners name.")
                Text("• **Repository:** The official name of the Repository.")
                Text("• **Primary Metric:** Focuses the widget on this statistic. (Downloads, Clones, Visits)")
                Text("  *(On the large widget, this sets which metric is used for the chart.)*")
                    .foregroundColor(.secondary)
            }
            .padding(.leading)
            
            // Side-by-side context menu & edit configuration sheet
            HStack(alignment: .top, spacing: 20) {
                Image("guide_widget_context_menu")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 210)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                
                Image("guide_widget_edit_sheet")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 210)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            }
            .padding(.vertical, 6)
            
            Text("Click any of the widgets to bring up the app.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 2)
        }
    }
    
    // MARK: - 2. Dashboard
    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("2. Dashboard (Trends and History) 📈")
                .font(.title2)
                .bold()
            
            Text("The Dashboard is the central hub for tracking your repository’s analytics.")
            
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("• **Inputs:** Enter your Repository Owner, Repository Name, and Global PAT at the top.\n  *(PAT — See section 5 for details)*")
                    
                    Text("• **Test Connection:** Click the **Test Connection** button to generate the metrics for the repository information you’ve input.")
                    
                    Text("• **Clear PAT:** Permanently clears the PAT.")
                    
                    (
                        Text("• **Public Metrics:** See your Stars (") +
                        Text(Image(systemName: "star.fill")).foregroundColor(.yellow) +
                        Text("), Forks (") +
                        Text(Image("git_fork")).foregroundColor(.blue) +
                        Text("), and Open Issues (") +
                        Text(Image(systemName: "ladybug.fill")).foregroundColor(.red) +
                        Text(") at a glance.")
                    )
                    
                    Text("• **Clear Data:** Use this to permanently delete the stored download history for the repository.")
                    
                    Text("• **Sync Cloud:** If you have 24/7 Cloud logger configured, click this to manually fetch the latest CSV history from your repository’s main branch.")
                    
                    Text("• **Setup Cloud Logger:** Copies the GitHub action script to your clipboard to enable 24/7 background logging.")
                    
                    Text("• **Charts:** View historical data over time. This history is built locally while your Mac is on, or 24/7 if you configure the Cloud Logger.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("guide_dashboard")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            }
        }
    }
    
    // MARK: - 3. Launchpad
    private var launchpadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("3. Launchpad ➣")
                .font(.title2)
                .bold()
            
            Text("The Launchpad is a quick-access dashboard for all of your favorite repositories.")
            
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("• **Adding Repos:** Type the Owner (e.g., 'apple') and Repository (e.g., 'swift') in the text fields, then click **Add to Launchpad**.")
                    
                    Text("• **Quick Links:** Each saved repository displays a set of shortcut buttons. Clicking these will instantly open that repository’s specific page (Traffic, Issues, Pull Requests, etc.) in your default web browser.")
                    
                    Text("• **Management:** To remove a repository from your Launchpad, simply click the red trash can icon (🗑) next to its name.")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("guide_launchpad")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 3)
            }
        }
    }
    
    // MARK: - 4. Diagnostics
    private var diagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("4. Diagnostics 🩺")
                .font(.title2)
                .bold()
            
            Text("The Diagnostics page is an advanced tool for troubleshooting app issues.")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• **System Paths:** View the directories where your app and widget are storing data on your Mac.")
                Text("• **Core Data Inspection:** View the raw JSON data being stored for your repositories (such as the cached GitHub responses).")
                Text("• **Cache Management:** Individually delete cached history or data files if they become corrupted or if you want to perform a hard reset.")
            }
            .padding(.leading)
        }
    }
    
    // MARK: - 5. Set up 24/7 Cloud Logging
    private var cloudLoggingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("5. Set up 24/7 Cloud Logging (Optional) ☁️")
                .font(.title2)
                .bold()
            
            Text("Generating a Personal Access Token")
                .font(.title3)
                .bold()
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("1. Go to **GitHub** → **Profile Icon** → **Settings** → **Developer Settings** → **Personal Access Tokens**.")
                Text("2. Click **‘Tokens (classic)’** and **‘Generate New Token (classic)’**.")
                Text("3. Select the `repo` scope for private repositories or `public_repo` for public ones.")
                Text("4. Generate and copy the token into the **Dashboard** tab of this app.")
            }
            .padding(.leading)
            
            Text("The widget tracks history when your Mac is on. For permanent 24/7 logging, use the Cloud Logger.")
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("1. In your GitHub Repository, go to **Settings** → **Actions** → **General**.")
                Text("2. Under Workflow permissions, select **Read and write permissions** and click **Save**.")
                Text("3. In your GitHub repository, go to **Settings** → **Secrets and variables** → **Actions**.")
                Text("4. Click **New repository secret**. Name it `TRAFFIC_PAT` and paste your Personal Access Token.")
                Text("5. Go to the **Dashboard** tab in this app and click **Setup Cloud Logger** to copy the script.")
                Text("6. In your GitHub repo, click **Add file** → **Create new file**.")
                Text("7. Name the file exactly: `.github/workflows/log_downloads.yml`")
                Text("8. Paste the script and commit directly to your main branch.")
            }
            .padding(.leading)
        }
    }
}
