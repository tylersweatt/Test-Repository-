import Foundation
import SwiftUI

// MARK: - AppSettings

final class AppSettings: ObservableObject {

    static let shared = AppSettings()

    // MARK: Stored preferences

    @AppStorage("defaultTranslation")      var defaultTranslation: String  = "KJV"
    @AppStorage("preacherName")            var preacherName: String         = ""
    @AppStorage("useBibleAPI")             var useBibleAPI: Bool            = false
    @AppStorage("bibleAPIKey")             var bibleAPIKey: String          = ""
    @AppStorage("apiBibleID")             var apiBibleID: String           = ""  // API.Bible translation ID
    @AppStorage("preferredColorScheme")    var preferredColorScheme: String = "system"
    @AppStorage("teleprompterSpeed")       var teleprompterSpeed: Double    = 50.0
    @AppStorage("exportFont")              var exportFont: String           = "Georgia"
    @AppStorage("hasCompletedOnboarding")  var hasCompletedOnboarding: Bool = false

    // MARK: - Initialiser

    private init() {}

    // MARK: - Computed

    /// Returns a SwiftUI ColorScheme override, or nil to follow system preference.
    var colorScheme: ColorScheme? {
        switch preferredColorScheme {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }
}
