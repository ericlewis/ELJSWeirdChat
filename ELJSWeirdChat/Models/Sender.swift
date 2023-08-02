import MessageKit
import SwiftData

@Model
class Sender: SenderType {

  var senderId: String
  var displayName: String

  init(senderId: String, displayName: String) {
    self.senderId = senderId
    self.displayName = displayName
  }
}
