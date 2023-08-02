import SwiftUI
import SwiftData

struct ChatDebugView: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    @Query(filter: #Predicate<Message> { $0.content?.isEmpty == false }, sort: \Message.sentDate)
    private var debugMessages: [Message]
    
    var body: some View {
        NavigationStack {
            ChatMessagesView(messages: debugMessages)
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Label("Dismiss", systemImage: "xmark")
                        }
                    }
                }
                .navigationTitle("Ai Debug")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
