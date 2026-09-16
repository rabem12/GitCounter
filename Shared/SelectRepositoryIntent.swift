import AppIntents
import WidgetKit

@available(macOS 14.0, *)
enum WidgetPrimaryMetric: String, AppEnum {
    case downloads
    case clones
    case views
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Primary Metric")
    
    static let caseDisplayRepresentations: [WidgetPrimaryMetric: DisplayRepresentation] = [
        .downloads: DisplayRepresentation(title: "Downloads"),
        .clones: DisplayRepresentation(title: "Clones"),
        .views: DisplayRepresentation(title: "Views")
    ]
}

@available(macOS 14.0, *)
struct SelectRepositoryIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Repository"
    static var description = IntentDescription("Configure the GitHub repository to track release downloads.")
    
    @Parameter(
        title: "Owner (Click to type)",
        default: "",
        inputOptions: String.IntentInputOptions(capitalizationType: .none, autocorrect: false),
        requestValueDialog: IntentDialog("Click to type owner, e.g. apple")
    )
    var owner: String
    
    @Parameter(
        title: "Repository (Click to type)",
        default: "",
        inputOptions: String.IntentInputOptions(capitalizationType: .none, autocorrect: false),
        requestValueDialog: IntentDialog("Click to type repo, e.g. swift")
    )
    var repo: String
    
    @Parameter(title: "Primary Metric", default: .downloads)
    var metric: WidgetPrimaryMetric?
    
    init() {
        self.owner = ""
        self.repo = ""
        self.metric = .downloads
    }
    
    init(owner: String, repo: String, metric: WidgetPrimaryMetric? = .downloads) {
        self.owner = owner
        self.repo = repo
        self.metric = metric
    }
}
