import SwiftUI

struct RootView: View {
    
    struct RootState {
        var showingPlugins = false
        var showingDetailedLog = false
    }
    
    @State
    private var state = RootState()
    
    var body: some View {
        NavigationStack {
            ChatView()
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing, content: makePluginsButton)
                    ToolbarItemGroup(placement: .topBarLeading) {
                        ClearChatButton()
                        makeDebugButton()
                    }
                }
                .navigationTitle("Ai")
                .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $state.showingPlugins, content: PluginManagerView.init)
        .sheet(isPresented: $state.showingDetailedLog, content: ChatDebugView.init)
    }
}

extension RootView {
    func makePluginsButton() -> some View {
        Button {
            state.showingPlugins.toggle()
        } label: {
            Label("Plugins", systemImage: "puzzlepiece.extension.fill")
        }
    }
    
    func makeDebugButton() -> some View {
        Button {
            state.showingDetailedLog.toggle()
        } label: {
            Label("Debug", systemImage: "ladybug.fill")
        }
    }
}

#Preview{
    RootView()
        .modelContainer(for: Plugin.self, inMemory: true)
}
