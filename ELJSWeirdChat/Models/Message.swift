import Foundation
import MessageKit
import OpenAI
import SwiftData

@Model
class Message: MessageType {
    var messageId: String
    var content: String?
    var sentDate: Date
    var user: Sender
    var name: String?
    var functionCall: ChatFunctionCall?
    
    init(
        messageId: String = UUID().uuidString,
        sentDate: Date = .now,
        role: Chat.Role,
        content: String? = nil,
        name: String? = nil,
        functionCall: ChatFunctionCall? = nil
    ) {
        self.user = .init(senderId: role.rawValue, displayName: role.rawValue)
        self.messageId = messageId
        self.sentDate = sentDate
        self.content = content
        self.name = name
        self.functionCall = functionCall
    }
    
    var sender: SenderType {
        user
    }
    
    var kind: MessageKind {
        .text(content ?? "")
    }
    
    var asChat: Chat {
        .init(
            role: Chat.Role(rawValue: self.user.senderId) ?? .user,
            content: self.content,
            name: self.name,
            functionCall: self.functionCall
        )
    }
}
