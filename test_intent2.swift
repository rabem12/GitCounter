import AppIntents
import WidgetKit

@available(macOS 14.0, *)
struct TestIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Test"
    
    @Parameter(title: "Owner", default: "")
    var owner: String
    
    init() {}
}
