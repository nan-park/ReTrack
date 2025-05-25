import SwiftUI

struct BoxView: View {
    @EnvironmentObject var postViewModel: PostViewModel
    let id: UUID
    @State private var currentPage = 0

    var body: some View {
        let imageHeight: CGFloat = 200
        if let post = postViewModel.posts.first(where: { $0.id == id }) {
            VStack(spacing: 0) {
                HStack {
                    Text(post.nickname)
                        .font(.system(size: 15))
                        .padding(.vertical, 14)
                    Spacer()
                }

                if !post.imageUrls.isEmpty {
                    TabView(selection: $currentPage) {
                        ForEach(post.imageUrls.indices, id: \.self) { index in
                            let urlString = post.imageUrls[index]
                            if let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: imageHeight)
                                        .clipped()
                                } placeholder: {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(.gray.opacity(0.2))
                                            .frame(height: imageHeight)
                                        ProgressView()
                                    }
                                }
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: imageHeight)
                    .cornerRadius(10)
//                    .padding(.horizontal, 30)
                }

                HStack {
                    Text(post.content)
                        .font(.system(size: 15))
                        .lineLimit(post.imageUrls.isEmpty ? 5 : 2)
                        .truncationMode(.tail)
                        .foregroundColor(.previewGray)
                        .padding(.bottom, 30)
                        .padding(.top, post.imageUrls.isEmpty ? 0 : 25)
                        .lineSpacing(4)
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 2)
            )
            .padding(.vertical, 10)
        }
    }
}
