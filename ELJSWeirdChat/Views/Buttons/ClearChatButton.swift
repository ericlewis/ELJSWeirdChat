import SwiftUI
import SwiftData

struct ClearChatButton: View {
    
    @Query
    private var messages: [Message]
    
    @Environment(\.modelContext)
    private var context
    
    var body: some View {
        Button {
            messages.forEach { context.delete($0) }
        } label: {
            Label("Clear", systemImage: "trash.fill")
        }
    }
}
