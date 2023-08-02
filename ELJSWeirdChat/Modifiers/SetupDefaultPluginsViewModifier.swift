import SwiftUI
import SwiftData

struct SetupDefaultPluginsViewModifier: ViewModifier {
    
    @Query(sort: \Plugin.name)
    private var plugins: [Plugin]
    
    @Environment(\.modelContext)
    private var context
    
    func body(content: Content) -> some View {
        content.onAppear(perform: setupInitialPlugins)
    }
    
    private func setupInitialPlugins() {
        if plugins.isEmpty {
            let initialPlugins: [Plugin] = [
                Plugin(
                    name: "random_number_generator",
                    modelDescription: "Generates a random number",
                    code: "return Math.random()"),
                Plugin(
                    name: "todays_date",
                    modelDescription: "Returns today's date and time.",
                    code: "new Date()"),
                Plugin(
                    name: "random_joke",
                    modelDescription: "Returns a random chuck norris joke from an API. Only tell the joke, do not add to it.",
                    code: "const res = await fetch('https://api.chucknorris.io/jokes/random').then(a => a.json()); return res.value;"),
                Plugin(
                    name: "btc_price",
                    modelDescription: "Returns the current price of bitcoin",
                    code: "const res = await fetch('https://api.coindesk.com/v1/bpi/currentprice.json').then(a => a.json()); return res;"),
            ]
            initialPlugins.forEach { context.insert($0) }
        }
    }
}

extension View {
    func setupDefaultPlugins() -> some View {
        modifier(SetupDefaultPluginsViewModifier())
    }
}
