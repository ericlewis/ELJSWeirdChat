import SwiftUI
import OpenAI

private struct SystemMessageKey: EnvironmentKey {
    static let defaultValue =  """
                    You are ChatGPT, a large language model trained by OpenAI, based on the GPT-3.5 architecture. You are chatting with the user via the ChatGPT iOS app. This means most of the time your lines should be a sentence or two, unless the user's request requires reasoning or long-form outputs. Never use emojis, unless explicitly asked to. Knowledge cutoff: 2021-09. Current date and time: \(Date.now).
                    """
}

extension EnvironmentValues {
    var systemMessage: String {
        get { self[SystemMessageKey.self] }
        set { self[SystemMessageKey.self] = newValue }
    }
}
