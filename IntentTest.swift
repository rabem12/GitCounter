import AppIntents
import WidgetKit

@available(macOS 14.0, *)
enum WidgetPrimaryMetric: String, AppEnum {
    case downloads, clones, views
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Primary Metric" }
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .downloads: "Downloads",
            .clones: "Clones",
            .views: "Views"
        ]
    }
}

@available(macOS 14.0, *)
struct RepoStatsIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Repository"
    static var description = IntentDescription("Configure the GitHub repository to track release downloads.")
    
    @Parameter(title: "Owner", default: "")
    var owner: String
    
    @Parameter(title: "Repository", default: "")
    var repo: String
    
    @Parameter(title: "Primary Metric", default: .downloads)
    var metric: WidgetPrimaryMetric
}
