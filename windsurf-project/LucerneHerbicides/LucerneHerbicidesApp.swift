import SwiftUI

@main
struct LucerneHerbicidesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(HerbicideStore())
        }
    }
}
