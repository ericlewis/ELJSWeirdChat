import SwiftUI

private struct ConfigurationKey: EnvironmentKey {
  static let defaultValue = AppConfiguration()
}

extension EnvironmentValues {
  var appConfiguration: AppConfiguration {
    get { self[ConfigurationKey.self] }
    set { self[ConfigurationKey.self] = newValue }
  }
}

extension View {
    func appConfiguration(_ configuration: AppConfiguration) -> some View {
      environment(\.appConfiguration, configuration)
  }
}
