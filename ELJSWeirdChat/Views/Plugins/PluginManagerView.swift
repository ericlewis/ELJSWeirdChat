import SwiftData
import SwiftUI

struct PluginManagerView: View {
    
    @Environment(\.modelContext)
    private var context
    
    @Query(sort: \Plugin.name)
    private var plugins: [Plugin]

    var body: some View {
        NavigationStack {
            List {
                ForEach(plugins) { plugin in
                    NavigationLink {
                        PluginView(plugin: plugin)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(plugin.name)
                                .font(.headline)
                            Text(plugin.modelDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deletePlugin)
            }
            .navigationTitle("Plugins")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    DismissButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    NavigationLink {
                        PluginView(plugin: nil)
                    } label: {
                        Label("New Plugin", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func deletePlugin(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                context.delete(plugins[index])
            }
        }
    }
}

#Preview{
    PluginManagerView()
        .modelContainer(for: Plugin.self, inMemory: true)
}
