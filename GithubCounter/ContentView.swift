import SwiftUI

struct ContentView: View {
    @State private var selection: SidebarItem? = .trends
    
    enum SidebarItem: Hashable {
        case trends
        case launchpad
        case notes
        case setupGuide
        case diagnostics
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Static Tab Column (fixed at 68pt matching traffic lights span)
            GeometryReader { geo in
                let availableHeight = geo.size.height
                let headerHeight: CGFloat = 72
                let bottomPadding: CGFloat = 12
                let totalGaps: CGFloat = 4 * 8
                let availableForTabs = availableHeight - headerHeight - bottomPadding - totalGaps
                let slotHeight = availableForTabs / 5
                
                let isCompact = slotHeight < 106
                let dynamicHeight = max(106, min(125, slotHeight))
                
                VStack(alignment: .center, spacing: 0) {
                    // Header (App Icon pinned to top below window traffic lights)
                    Image("SidebarAppIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                        .help("Github Counter")
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    
                    // Pinned Tab List (Centered 56pt pills)
                    VStack(spacing: isCompact ? 6 : 8) {
                        SidebarButton(
                            title: "Dashboard",
                            systemImage: "chart.xyaxis.line",
                            iconColor: .blue,
                            item: .trends,
                            selection: $selection,
                            isCompact: isCompact,
                            dynamicHeight: dynamicHeight
                        )
                        SidebarButton(
                            title: "Launchpad",
                            systemImage: "paperplane.fill",
                            iconColor: .orange,
                            item: .launchpad,
                            selection: $selection,
                            isCompact: isCompact,
                            dynamicHeight: dynamicHeight
                        )
                        SidebarButton(
                            title: "Notes",
                            systemImage: "note.text",
                            iconColor: .yellow,
                            item: .notes,
                            selection: $selection,
                            isCompact: isCompact,
                            dynamicHeight: dynamicHeight
                        )
                        SidebarButton(
                            title: "Setup Guide",
                            systemImage: "book.fill",
                            iconColor: .green,
                            item: .setupGuide,
                            selection: $selection,
                            isCompact: isCompact,
                            dynamicHeight: dynamicHeight
                        )
                        SidebarButton(
                            title: "Diagnostics",
                            systemImage: "stethoscope",
                            iconColor: .red,
                            item: .diagnostics,
                            selection: $selection,
                            isCompact: isCompact,
                            dynamicHeight: dynamicHeight
                        )
                    }
                    
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(width: 68)
            .background(Material.ultraThin)
            
            Divider()
            
            // Detail Area
            Group {
                if let selection = selection {
                    switch selection {
                    case .trends:
                        TrendsView()
                    case .launchpad:
                        LaunchpadView()
                    case .notes:
                        NotesView()
                    case .setupGuide:
                        SetupGuideView()
                    case .diagnostics:
                        DiagnosticsView()
                    }
                } else {
                    Text("Select an item from the sidebar")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Link(destination: URL(string: "https://ko-fi.com/raven_lord")!) {
                    HStack {
                        Text("☕️")
                        Text("Support the Developer")
                            .fontWeight(.medium)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didReceiveDeepLink)) { _ in
            DiagnosticsManager.shared.logRoutingEvent("ContentView received .didReceiveDeepLink notification. Setting selection to .trends.")
            selection = .trends
        }
    }
}

struct SidebarButton: View {
    let title: String
    let systemImage: String
    let iconColor: Color
    let item: ContentView.SidebarItem
    @Binding var selection: ContentView.SidebarItem?
    var isCompact: Bool = false
    var dynamicHeight: CGFloat = 106
    
    @State private var isHovered = false
    
    var isSelected: Bool {
        selection == item
    }
    
    var gradient: LinearGradient {
        switch item {
        case .trends:
            return LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
        case .launchpad:
            return LinearGradient(colors: [.orange, Color(red: 0.95, green: 0.3, blue: 0.2)], startPoint: .leading, endPoint: .trailing)
        case .notes:
            return LinearGradient(colors: [Color(red: 0.9, green: 0.65, blue: 0.0), .orange], startPoint: .leading, endPoint: .trailing)
        case .setupGuide:
            return LinearGradient(colors: [.green, .teal], startPoint: .leading, endPoint: .trailing)
        case .diagnostics:
            return LinearGradient(colors: [.red, .purple], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    var body: some View {
        Button(action: {
            selection = item
        }) {
            if isCompact {
                // Compact Icon-Only Mode (Unrotated, centered exact SF Symbol)
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : iconColor)
                    .frame(width: 56, height: 44)
                    .background(
                        ZStack {
                            if isSelected {
                                gradient
                                    .cornerRadius(10)
                            } else if isHovered {
                                Color.primary.opacity(0.1)
                                    .cornerRadius(10)
                            }
                        }
                    )
                    .contentShape(Rectangle())
            } else {
                // Full Mode: Rotated Text + exact SF Symbol
                HStack(spacing: 7) {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isSelected ? .white : iconColor)
                    
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                        .lineLimit(1)
                }
                .frame(width: dynamicHeight, height: 56)
                .background(
                    ZStack {
                        if isSelected {
                            gradient
                                .cornerRadius(10)
                        } else if isHovered {
                            Color.primary.opacity(0.1)
                                .cornerRadius(10)
                        }
                    }
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 56, height: dynamicHeight)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
        .help(title)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}


