import Foundation
import OpenAI
import SwiftData

@Model
final class Plugin {
    var name: String
    var modelDescription: String
    var schema: String
    var code: String
    var isEnabled: Bool
    
    init(
        name: String,
        modelDescription: String,
        schema: JSONSchema = JSONSchema(
            type: .object,
            properties: [:]
        ),
        code: String,
        isEnabled: Bool = true
    ) {
        self.name = name
        self.modelDescription = modelDescription
        self.schema = try! String(data: JSONEncoder().encode(schema), encoding: .utf8)!
        self.code = code
        self.isEnabled = isEnabled
    }
}

extension Plugin {
    var functionDeclaration: ChatFunctionDeclaration {
        try! .init(
            name: self.name,
            description: self.modelDescription,
            parameters: JSONDecoder().decode(JSONSchema.self, from: schema.data(using: .utf8)!)
        )
    }
}
