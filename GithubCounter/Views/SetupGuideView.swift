import SwiftUI

struct SetupGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("How to Configure Your Widget")
                    .font(.title)
                    .bold()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("1. Add the Widget to your Desktop")
                        .font(.title3)
                        .bold()
                    Text("Open the macOS Notification Center, click 'Edit Widgets', search for 'Github Counter', and drag the widget to your desktop.")
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("2. Right-click & Edit Widget")
                        .font(.title3)
                        .bold()
                    Text("Right-click the widget on your desktop and select 'Edit “GitHub Release Stats”' (or 'Edit Widget').")
                    
                    Image(systemName: "cursorarrow.rays")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("3. Enter Repository Details")
                        .font(.title3)
                        .bold()
                    Text("For a repository URL like `https://github.com/apple/swift`:")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• **Repository Owner**: apple")
                        Text("• **Repository Name**: swift")
                    }
                    .padding(.leading)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("4. Generate a Personal Access Token (Optional)")
                        .font(.title3)
                        .bold()
                    Text("Required for tracking Private Repositories or getting real-time Traffic Data (Clones/Views). Also increases GitHub's API rate limit from 60 to 5,000 requests per hour.")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("1. Go to GitHub.com → Profile Icon → Settings → Developer Settings → Personal Access Tokens.")
                        Text("2. Click 'Tokens (classic)' and 'Generate New Token (classic)'.")
                        Text("3. Select the `repo` scope for private repositories or `public_repo` for public ones.")
                        Text("4. Generate and copy the token into the **Repo Sandbox** tab of this app. It will apply to all your widgets automatically!")
                    }
                    .padding(.leading)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("5. Set Up 24/7 Cloud Logging (Optional)")
                        .font(.title3)
                        .bold()
                    Text("The widget tracks history when your Mac is on. For permanent 24/7 logging, use the Cloud Logger.")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("1. In your GitHub repository, go to **Settings** → **Actions** → **General**.")
                        Text("2. Under Workflow permissions, select **Read and write permissions** and Save.")
                        Text("3. In your GitHub repository, go to **Settings** → **Secrets and variables** → **Actions**.")
                        Text("4. Click **New repository secret**. Name it `TRAFFIC_PAT` and paste your Personal Access Token.")
                        Text("5. Go to the **Trends & History** tab in this app and click **Setup Cloud Logger** to copy the script.")
                        Text("6. In your GitHub repo, click **Add file** → **Create new file**.")
                        Text("7. Name the file exactly: `.github/workflows/log_downloads.yml`")
                        Text("8. Paste the script and commit directly to your main branch.")
                    }
                    .padding(.leading)
                }
                
                Spacer()
            }
            .padding(32)
        }
    }
}
