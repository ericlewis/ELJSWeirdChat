import SwiftUI
import OpenAI

private struct ModelKey: EnvironmentKey {
    static let defaultValue = Model.gpt3_5Turbo_16k_0613
}

extension EnvironmentValues {
    var model: Model {
        get { self[ModelKey.self] }
        set { self[ModelKey.self] = newValue }
    }
}
