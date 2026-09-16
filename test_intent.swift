import Foundation
import AppIntents

@available(macOS 14.0, *)
enum WidgetDisplayMetric: String, AppEnum {
    case downloads = "downloads"
    case clones = "clones"
    case views = "views"
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Primary Metric"
    
    static let caseDisplayRepresentations: [WidgetDisplayMetric: DisplayRepresentation] = [
        .downloads: DisplayRepresentation(title: "Downloads"),
        .clones: DisplayRepresentation(title: "Clones"),
        .views: DisplayRepresentation(title: "Views")
    ]
}

@available(macOS 14.0, *)
struct RepositoryConfigIntent: AppIntent {
    static var title: LocalizedStringResource = "Select Repository"
    
    @Parameter(title: "Primary Metric", default: .downloads)
    var displayMetric: WidgetDisplayMetric
    
    init() {}
    
    init(displayMetric: WidgetDisplayMetric = .downloads) {
        self.displayMetric = displayMetric
    }
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

if #available(macOS 14.0, *) {
    let intent = RepositoryConfigIntent(displayMetric: .clones)
    print("Intent display metric: \(intent.displayMetric.rawValue)")
}
