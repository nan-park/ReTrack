import PhotosUI
import SwiftUI

struct EditPostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var postViewModel: PostViewModel
    @Binding var path: [ViewType]
    @State var showToast: Bool = false
    @State var toastMessage: String = ""

    let id: UUID
    @State var nickname: String = ""
    @State var content: String = ""
    @State var imageUrls: [String] = []
    let post: Post

    var onSave: (UUID, String, String, [UIImage]) -> Void
    @StateObject private var keyboard = KeyboardResponder()

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var currentPage = 0
    @State private var showFullScreen = false
    @State private var showPhotoPicker: Bool = false

    var displayedImages: [DisplayedImage] {
        if !selectedImages.isEmpty {
            return selectedImages.map { DisplayedImage(uiImage: $0, url: nil) }
        } else {
            return imageUrls.map { DisplayedImage(uiImage: nil, url: $0) }
        }
    }

    init(
        path: Binding<[ViewType]>,
        post: Post,
        onSave: @escaping (UUID, String, String, [UIImage]) -> Void
    ) {
        self._path = path
        self.post = post
        self.onSave = onSave
        self.id = post.id

        self._nickname = State(initialValue: post.nickname)
        self._content = State(initialValue: post.content)
        self._imageUrls = State(initialValue: post.imageUrls)
    }

    var body: some View {
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

                    // register Button
                    Button {
                        toastMessage = postViewModel.checkCondition(
                            post.nickname, post.content, "same", "same")
                        print(toastMessage)
                        if !toastMessage.isEmpty {

                            print(toastMessage)
                            showToast = true

                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 2.0
                            ) {
                                showToast = false
                                toastMessage = ""
                            }
                        } else {
                            if selectedImages.isEmpty {
                                postViewModel.updatePostWithImageUrls(
                                    id: id, content: content,
                                    imageUrls: imageUrls)
                                postViewModel.isLoading = true
                                path.removeLast()
                            } else {
                                // ✅ 새 이미지 선택된 경우
                                onSave(id, nickname, content, selectedImages)
                                postViewModel.isLoading = true
                                path.removeLast()
                            }
                        }
                    } label: {
                        Text("저장")
                            .foregroundColor(.black)
                            .font(.custom("IBMPlexSansKR-Regular", size: 18))
                    }
                }
                Spacer()
                    .frame(height: 9)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.dividerGray)

                Spacer()
                    .frame(height: 30)

                ZStack(alignment: .top) {
                    Rectangle()
                        .frame(height: 210)
                        .foregroundColor(.imageAreaGray)
                    if displayedImages.isEmpty {
                        // 중앙 텍스트
                        Text("이미지를 삽입하려면\n탭하세요")
                            .font(.custom("IBMPlexSansKR-Regular", size: 18))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, maxHeight: 210)
                    } else {
                        // 이미지 보여주는 TabView
                        TabView(selection: $currentPage) {
                            ForEach(displayedImages.indices, id: \.self) {
                                index in
                                let item = displayedImages[index]
                                ZStack(alignment: .topTrailing) {
                                    if let image = item.uiImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .tag(index)
                                            .frame(height: 210)
                                            .clipped()
                                    } else if let url = item.url,
                                        let imgURL = URL(string: url)
                                    {
                                        AsyncImage(url: imgURL) { image in
                                            image.resizable()
                                                .scaledToFill()
                                                .frame(height: 210)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView().frame(height: 210)
                                        }
                                    }
                                }
                            }
                        }
                        .tabViewStyle(
                            PageTabViewStyle(indexDisplayMode: .automatic)
                        )
                        .frame(height: 210)
                        .contentShape(Rectangle())  // 제스처 감지 가능하게
                        Text("이미지를 변경하려면 탭하세요")
                            .font(.custom("IBMPlexSansKR-Regular", size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(10)
                            .padding(.top, 10)
                            .padding(.leading, 12)
                    }
                }
                .onTapGesture {
                    showPhotoPicker = true
                }
                .photosPicker(
                    isPresented: $showPhotoPicker,
                    selection: $selectedItems,
                    maxSelectionCount: 5,
                    matching: .images
                )
                .onChange(of: selectedItems) {
                    Task {
                        selectedImages.removeAll()
                        for item in selectedItems {
                            if let data = try? await item.loadTransferable(
                                type: Data.self),
                                let uiImage = UIImage(data: data)
                            {
                                selectedImages.append(uiImage)
                            }
                        }
                    }
                }

                Spacer()
                    .frame(height: 20)
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $content)
                        .frame(height: 280)
                        .padding(.horizontal, 7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.black, lineWidth: 1)
                        )
                        .font(.custom("IBMPlexSansKR-Regular", size: 15))
                        .foregroundColor(.black)
                    if content.isEmpty {
                        Text("텍스트를 입력하세요")
                            .font(.custom("IBMPlexSans-Regular", size: 15))
                            .foregroundColor(.previewGray)
                            .padding(.leading, 11)
                            .padding(.top, 10)
                    }
                }
                Spacer()

            }
            .padding(.horizontal, 32)
            .navigationBarBackButtonHidden(true)
            .padding(.bottom, keyboard.currentHeight)
            .animation(.easeOut(duration: 0.25), value: keyboard.currentHeight)
            .onTapGesture {
                hideKeyboard()

            }

            // toast stack
            VStack {
                Spacer()
                if showToast {
                    Text(toastMessage)
                        .font(.custom("IBMPlexSansKR-Regular", size: 18))
                        .foregroundColor(.white)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 10)
                        //                    .background((Color.black).opacity(0.7))
                        .background(.previewGray)
                        .cornerRadius(10)
                }
                Spacer()
                    .frame(height: 20)
            }
        }
    }
}

//#Preview {
//    EditPostView(
//        path: .constant([]), id: UUID(), nickname: "Nika", content: "ddd",
//        imageUrl: [], onSave: { _, _, _, _ in }
//    )
//    .environmentObject(PostViewModel())
//}
