//
//  LaunchpadView.swift
//  GitCounter
//
//  Copyright © 2026 Black Pinion LLC. All rights reserved.
//

import SwiftUI

struct LaunchpadView: View {
    @StateObject private var launchpadManager = LaunchpadManager()
    @State private var newOwner = ""
    @State private var newRepo = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Input Area
            VStack(alignment: .leading, spacing: 16) {
                Text("Launchpad")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Add your favorite repositories here to quickly access their GitHub dashboards.")
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("Owner (e.g., apple)", text: $newOwner)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Repository (e.g., swift)", text: $newRepo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: addRepo) {
                        Text("Add to Launchpad")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(newOwner.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newRepo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Saved Repositories Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 350, maximum: .infinity), spacing: 16)], spacing: 16) {
                    ForEach(launchpadManager.savedRepos, id: \.self) { repoIdentifier in
                        LaunchpadCard(repoIdentifier: repoIdentifier) {
                            launchpadManager.removeRepo(repoIdentifier)
                        }
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
    
    private func addRepo() {
        launchpadManager.addRepo(owner: newOwner, repo: newRepo)
        newOwner = ""
        newRepo = ""
    }
}

struct LaunchpadCard: View {
    let repoIdentifier: String
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(repoIdentifier)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Remove from Launchpad")
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    QuickLinkButton(title: "Traffic", icon: "chart.xyaxis.line", urlString: "https://github.com/\(repoIdentifier)/graphs/traffic")
                    QuickLinkButton(title: "Issues", icon: "smallcircle.filled.circle", urlString: "https://github.com/\(repoIdentifier)/issues")
                    QuickLinkButton(title: "Pull Requests", icon: "arrow.triangle.pull", urlString: "https://github.com/\(repoIdentifier)/pulls")
                }
                HStack(spacing: 8) {
                    QuickLinkButton(title: "Actions", icon: "play.circle", urlString: "https://github.com/\(repoIdentifier)/actions")
                    QuickLinkButton(title: "Releases", icon: "tag", urlString: "https://github.com/\(repoIdentifier)/releases")
                    QuickLinkButton(title: "Settings", icon: "gearshape", urlString: "https://github.com/\(repoIdentifier)/settings")
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuickLinkButton: View {
    let title: String
    let icon: String
    let urlString: String
    
    var body: some View {
        Button(action: {
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
        .help("Open \(title) on GitHub")
    }
}
