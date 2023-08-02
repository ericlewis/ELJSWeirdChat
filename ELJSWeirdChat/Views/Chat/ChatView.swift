import SwiftUI
import SwiftData

struct ChatView: View {
    
    @Query(filter: #Predicate<Message> { $0.content?.isEmpty == false }, sort: \Message.sentDate)
    private var messages: [Message]
    
    var body: some View {
        ChatMessagesView(messages: messages.filter({ $0.sender.senderId != "function" }))
            .ignoresSafeArea()
    }
}
