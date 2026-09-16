import AppIntents
import WidgetKit

struct RefreshWidgetIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh GitHub Stats"
    static var description = IntentDescription("Forces the widget to fetch the latest data from GitHub.")

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
