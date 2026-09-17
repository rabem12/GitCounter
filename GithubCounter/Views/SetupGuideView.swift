import SwiftUI

struct SetupGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                Text("Github Counter Manual")
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
            }
            .padding(32)
        }
    }
    
    private var widgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("1. Widget Functionality")
                .font(.title2)
                .bold()
            
            Text("Adding and Editing the Widget")
                .font(.title3)
                .bold()
                .padding(.top, 8)
            Text("Open the macOS Notification Center, click 'Edit Widgets', search for 'Github Counter', and drag the widget to your desktop. Right-click the widget and select 'Edit “GitHub Release Stats”' to configure the owner, repository, and primary metric.")
            
            Image("widget_settings")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.vertical, 8)
            
            Text("Widget Sizes")
                .font(.title3)
                .bold()
                .padding(.top, 8)
            Text("The app provides three widget sizes to fit your needs:")
            
            HStack(alignment: .top, spacing: 20) {
                VStack {
                    Image("widget_small")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                    Text("Small (Single Metric)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Image("widget_medium")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                    Text("Medium (All Metrics)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
            
            VStack(alignment: .leading) {
                Image("widget_large")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300)
                    .cornerRadius(16)
                    .shadow(radius: 4)
                Text("Large (Metrics + Trend Graph)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("⚠️ Authorization Note")
                    .font(.headline)
                Text("To display Traffic Data (Clones/Views) and `+# today` deltas, you must provide a Personal Access Token (PAT) with the correct permissions in the Dashboard tab. Otherwise, these fields will show 'Data Not Public'.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(8)
        }
    }
    
    private var dashboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("2. Dashboard (Trends & History)")
                .font(.title2)
                .bold()
            
            Text("The Dashboard is the central hub for tracking your repository's analytics.")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• **Inputs:** Enter your Repository Owner, Repository Name, and Global PAT at the top.")
                Text("• **Test Connection:** Click this button to apply your inputs globally. This fetches the latest data for your charts and updates the widgets.")
                Text("• **Public Metrics:** See your Stars, Forks, and Open Issues at a glance.")
                Text("• **Clear Data:** Use this to permanently delete the stored download history for the current repository.")
                Text("• **Sync Cloud:** If you have the 24/7 Cloud Logger configured, click this to manually fetch the latest CSV history from your repository's main branch.")
                Text("• **Setup Cloud Logger:** Copies the GitHub Action script to your clipboard to enable 24/7 background logging.")
                Text("• **Charts:** View historical data over time. This history is built locally while your Mac is on, or 24/7 if you configure the Cloud Logger.")
            }
            .padding(.leading)
        }
    }
    
    private var launchpadSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("3. Launchpad")
                .font(.title2)
                .bold()
            
            Text("The Launchpad is a quick-access dashboard for all your favorite repositories.")
            
            Image("launchpad_guide")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 250)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• **Adding Repos:** Type the Owner (e.g., 'apple') and Repository name (e.g., 'swift') in the text fields, then click **Add to Launchpad**.")
                Text("• **Quick Links:** Each saved repository displays a set of shortcut buttons. Clicking these will instantly open that repository's specific page (Traffic, Issues, Pull Requests, etc.) in your default web browser.")
                Text("• **Management:** To remove a repository from your Launchpad, simply click the red trash can icon next to its name.")
            }
            .padding(.leading)
        }
    }
    
    private var diagnosticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("4. Diagnostics")
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
    
    private var cloudLoggingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("5. Set Up 24/7 Cloud Logging (Optional)")
                .font(.title2)
                .bold()
            
            Text("The widget tracks history when your Mac is on. For permanent 24/7 logging, use the Cloud Logger.")
            
            VStack(alignment: .leading, spacing: 4) {
                Text("1. In your GitHub repository, go to **Settings** → **Actions** → **General**.")
                Text("2. Under Workflow permissions, select **Read and write permissions** and Save.")
                Text("3. In your GitHub repository, go to **Settings** → **Secrets and variables** → **Actions**.")
                Text("4. Click **New repository secret**. Name it `TRAFFIC_PAT` and paste your Personal Access Token.")
                Text("5. Go to the **Dashboard** tab in this app and click **Setup Cloud Logger** to copy the script.")
                Text("6. In your GitHub repo, click **Add file** → **Create new file**.")
                Text("7. Name the file exactly: `.github/workflows/log_downloads.yml`")
                Text("8. Paste the script and commit directly to your main branch.")
            }
            .padding(.leading)
            
            Text("Generating a Personal Access Token")
                .font(.headline)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("1. Go to GitHub.com → Profile Icon → Settings → Developer Settings → Personal Access Tokens.")
                Text("2. Click 'Tokens (classic)' and 'Generate New Token (classic)'.")
                Text("3. Select the `repo` scope for private repositories or `public_repo` for public ones.")
                Text("4. Generate and copy the token into the **Dashboard** tab of this app.")
            }
            .padding(.leading)
        }
    }
}
