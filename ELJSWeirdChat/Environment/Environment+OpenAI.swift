import SwiftUI
import OpenAI

private struct OpenAiKey: EnvironmentKey {
  static let defaultValue = OpenAI(apiToken: "")
}

extension EnvironmentValues {
  var openai: OpenAI {
    get { self[OpenAiKey.self] }
    set { self[OpenAiKey.self] = newValue }
  }
}

extension View {
  func openai(_ apiToken: String) -> some View {
      environment(\.openai, .init(apiToken: apiToken))
  }
}
