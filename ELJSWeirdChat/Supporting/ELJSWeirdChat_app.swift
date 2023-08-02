import SwiftData
import SwiftUI
import OpenAI

struct AppConfiguration {
    
    let openai: OpenAI
    let model: Model
    
    let demoPlugins: [Plugin] = [
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
    
    init(apiToken: String = "YOURSHITGOESHERE", model: Model = .gpt3_5Turbo_16k_0613) {
        self.openai = OpenAI(apiToken: apiToken)
        self.model = model
    }
}

@main
struct ELJSWeirdChat_app: App {

  var body: some Scene {
    WindowGroup {
      RootView()
    }
    .modelContainer(for: [
      Plugin.self,
      Message.self,
      Sender.self,
    ])
  }
}
