import SwiftUI

struct PostDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var postViewModel: PostViewModel
    @State var inputPassword: String = ""
    @State var isShowingAlert: Bool = false
    @State var isShowingDeleteAlert: Bool = false
    @State var buttonType: String = ""

    @Binding var path: [ViewType]
    let id: UUID

    var body: some View {
        if let post = postViewModel.posts.first(where: { $0.id == id }) {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        // backward Button
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                        Spacer()

                        // trash Button
                        Button {
                            buttonType = "삭제"
                            isShowingAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                        .padding(.trailing, 14)

                        // update Button
                        Button {
                            buttonType = "수정"
                            isShowingAlert = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                        .frame(height: 9)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.dividerGray)
                    ScrollView {
                        VStack {
                            Spacer()
                                .frame(height: 24)

                            HStack {
                                Text(post.nickname)
                                    .font(
                                        .custom(
                                            "IBMPlexSansKR-Regular", size: 18))
                                Spacer()
                                //                            Text("2025.04.10 오후 09:28")
                                Text(post.createdAt.formattedKoreanStyle())
                                    .font(
                                        .custom(
                                            "IBMPlexSansKR-Regular", size: 15)
                                    )
                                    .foregroundColor(.previewGray)
                            }
                            if !post.imageUrls.isEmpty {
                                TabView {
                                    ForEach(post.imageUrls, id: \.self) {
                                        urlString in
                                        if let url = URL(string: urlString) {
                                            AsyncImage(url: url) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(height: 220)
                                                    .clipped()
                                            } placeholder: {
                                                ZStack {
                                                    Rectangle()
                                                        .foregroundColor(
                                                            .gray.opacity(0.2)
                                                        )
                                                        .frame(height: 220)
                                                    ProgressView()
                                                }
                                            }
                                        }
                                    }
                                }
                                .tabViewStyle(
                                    PageTabViewStyle(
                                        indexDisplayMode: .automatic)
                                )
                                .frame(height: 220)
                                .cornerRadius(10)
                                .padding(.vertical, 16)
                            } else {
                                Spacer()
                                    .frame(height: 10)
                            }

                            HStack {
                                Text(post.content)
                                    .font(
                                        .custom(
                                            "IBMPlexSansKR-Regular", size: 15)
                                    )
                                    .lineSpacing(4)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)

                if postViewModel.isLoading {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("변경사항을 불러오는 중...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }

                if isShowingAlert || isShowingDeleteAlert {
                    Rectangle()
                        .foregroundColor(.black.opacity(0.5))
                        .ignoresSafeArea()
                }

                // Alert Stack
                if isShowingAlert {
                    AlertPopupView(
                        isShowingAlert: $isShowingAlert,
                        isShowingDeleteAlert: $isShowingDeleteAlert,
                        inputPassword: $inputPassword, id: id,
                        buttonType: $buttonType, path: $path)
                }
                if isShowingDeleteAlert {
                    DeleteAlertPopupView(
                        isShowingDeleteAlert: $isShowingDeleteAlert,
                        path: $path,
                        id: id)
                }

            }
            .navigationBarBackButtonHidden(true)

        }

    }
}

//#Preview {
//    PostDetailView(path: .constant([]), id: UUID())
//        .environmentObject(PostViewModel())
//}
