import SwiftUI

struct PluginView: View {

    @Environment(\.dismiss)
    private var dismiss
    
    @Environment(\.modelContext)
    private var context

    @State
    private var name = ""
    
    @State
    private var modelDescription = ""
    
    @State
    private var code = ""

    var plugin: Plugin?
    
    var body: some View {
        Form {
            inputSection
            editSection
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                saveButton
            }
        }
        .navigationTitle(plugin?.name ?? (name.isEmpty ? "New Plugin" : name))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupView)
        .onDisappear(perform: updatePlugin)
        .interactiveDismissDisabled()
    }
}

private extension PluginView {
    var inputSection: some View {
        Section {
            TextField("Name", text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            TextField("Model Description", text: $modelDescription, axis: .vertical)
        }
    }
    
    var editSection: some View {
        Section {
            NavigationLink("Edit Code") {
                CodeEditorView(name: $name, code: $code)
            }
        }
    }
    
    @ViewBuilder
    var saveButton: some View {
        if plugin == nil {
            Button("Save") {
                context.insert(Plugin(name: self.name, modelDescription: self.modelDescription, code: self.code))
                dismiss()
            }
        }
    }
    
    func setupView() {
        if let plugin, name.isEmpty {
            self.name = plugin.name
            self.modelDescription = plugin.modelDescription
            self.code = plugin.code
        } else if name.isEmpty {
            self.name = "function_\(Int.random(in: 0...10000))"
            self.modelDescription = "returns 1337 when asked who is leet"
            self.code = "return 1337;"
        }
    }
    
    func updatePlugin() {
        if let plugin {
            plugin.name = self.name
            plugin.modelDescription = self.modelDescription
            plugin.code = self.code
        }
    }
}
