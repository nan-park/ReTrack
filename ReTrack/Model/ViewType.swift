import SwiftUI

enum ViewType: Hashable {
    case postDetailView(id: UUID)
    case createPostView
    case editPostView(post: Post)
}
