import Foundation

public struct User: Identifiable, Codable {
    public var id: String
    public var name: String

    public init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}
