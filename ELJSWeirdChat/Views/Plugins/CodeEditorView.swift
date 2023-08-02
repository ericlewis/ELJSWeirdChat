import CodeEditor
import SwiftUI

struct CodeEditorView: View {
    
    @Binding
    var name: String
    
    @Binding
    var code: String
    
    var body: some View {
        CodeEditor(
            source: $code,
            language: .javascript
        )
        .ignoresSafeArea(.container, edges: .bottom)
        .onChange(of: code) { _, _ in
            self.code =
            code
                .replacingOccurrences(of: "“", with: "\"")
                .replacingOccurrences(of: "”", with: "\"")
                .replacingOccurrences(of: "‘", with: "'")
                .replacingOccurrences(of: "’", with: "'")
        }
        .navigationTitle(name)
        .interactiveDismissDisabled()
    }
}

#Preview{
    CodeEditorView(name: .constant(""), code: .constant(""))
}
