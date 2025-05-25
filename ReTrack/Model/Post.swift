import SwiftUI

struct Post: Identifiable, Codable, Hashable {
    let id: UUID
    var nickname: String
    let password: String
    var content: String
    var imageUrls: [String]
    var createdAt: Date
}
