import SwiftUI

@main
struct HerbicideGuideApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(HerbicideStore())
        }
    }
}
