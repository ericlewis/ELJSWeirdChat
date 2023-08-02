import SwiftUI

struct DismissButton: View {
    
    @Environment(\.dismiss)
    private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Label("Dismiss", systemImage: "xmark")
        }
    }
}
