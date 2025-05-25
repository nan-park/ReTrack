import PhotosUI
import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var postViewModel: PostViewModel
    @State var inputContent: String = ""
    @State var inputNickname: String = ""
    @State var inputPassword: String = ""
    @State var inputPasswordConfirm: String = ""
    @Binding var path: [ViewType]
    @State var showToast: Bool = false
    @State var toastMessage: String = ""

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showFullScreen = false
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
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
                                inputNickname, inputContent, inputPassword,
                                inputPasswordConfirm)
                            if !toastMessage.isEmpty {  // toast message
                                
                                print(toastMessage)
                                showToast = true
                                
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 2.0
                                ) {
                                    showToast = false
                                    toastMessage = ""
                                }
                            } else {  // register
                                postViewModel.addPostWithImages(
                                    nickname: inputNickname,
                                    password: inputPassword,
                                    content: inputContent,
                                    images: selectedImages)
                                path = []
                                postViewModel.isLoading = true
                                dismiss()
                            }
                            
                        } label: {
                            Text("등록")
                                .foregroundColor(.black)
                                .font(.custom("IBMPlexSansKR-Regular", size: 18))
                        }
                    }
                    Spacer()
                        .frame(height: 9)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.dividerGray)
                }
                .padding(.horizontal, 32)
                
                ScrollView {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 30)
                        
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: 5,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack {
                                Rectangle()
                                    .frame(height: 210)
                                    .foregroundColor(.imageAreaGray)
                                if selectedImages.isEmpty {
                                    Text("이미지를 삽입하려면\n탭하세요")
                                        .font(
                                            .custom(
                                                "IBMPlexSansKR-Regular", size: 18)
                                        )
                                        .multilineTextAlignment(.center)
                                } else {
                                    TabView(selection: $currentPage) {
                                        ForEach(
                                            Array(selectedImages.enumerated()),
                                            id: \.offset
                                        ) { index, image in
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .tag(index)
                                                .frame(height: 210)
                                                .clipped()
                                                .onTapGesture {
                                                    showFullScreen = true
                                                }
                                        }
                                    }
                                    .tabViewStyle(
                                        PageTabViewStyle(
                                            indexDisplayMode: .automatic)
                                    )
                                    .frame(height: 210)
                                    
                                    VStack {
                                        Text("이미지를 변경하려면 탭하세요")
                                            .font(
                                                .custom(
                                                    "IBMPlexSansKR-Regular",
                                                    size: 16)
                                            )
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(8)
                                            .padding(.top, 10)
                                        Spacer()
                                    }
                                }
                            }
                        }
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
                            TextEditor(text: $inputContent)
                                .frame(height: 280)
                                .padding(.horizontal, 7)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.black, lineWidth: 1)
                                )
                                .font(.custom("IBMPlexSansKR-Regular", size: 16))
                                .foregroundColor(.black)
                            if inputContent.isEmpty {
                                Text("텍스트를 입력하세요")
                                    .font(.custom("IBMPlexSans-Regular", size: 16))
                                    .foregroundColor(.previewGray)
                                    .padding(.leading, 11)
                                    .padding(.top, 10)
                            }
                        }
                        Spacer()
                            .frame(height: 35)
                        
                        HStack {
                            Text("게시자 정보")
                                .font(.custom("IBMPlexSansKR-Regular", size: 18))
                            Spacer()
                        }
                        Spacer()
                            .frame(height: 20)
                        
                        TextField("닉네임", text: $inputNickname)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(.imageAreaGray)
                            .cornerRadius(8)
                            .font(.custom("IBMPlexSansKR-Regular", size: 16))
                        Spacer()
                            .frame(height: 18)
                        
                        SecureField("비밀번호", text: $inputPassword)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(.imageAreaGray)
                            .cornerRadius(8)
                            .font(.custom("IBMPlexSansKR-Regular", size: 16))
                        Spacer()
                            .frame(height: 18)
                        
                        SecureField("비밀번호 확인", text: $inputPasswordConfirm)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(.imageAreaGray)
                            .font(.custom("IBMPlexSansKR-Regular", size: 16))
                            .cornerRadius(8)
                        Spacer()
                            .frame(height: 5)
                        if inputPassword != inputPasswordConfirm {
                            HStack {
                                Text("*비밀번호가 맞지 않습니다")
                                    .font(
                                        .custom("IBMPlexSansKR-Regular", size: 12)
                                    )
                                    .foregroundColor(.alertRed)
                                    .padding(.leading, 16)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                }
                
            }
            //            .padding(.horizontal, 32)
            // toast stack
            VStack {
                Spacer()
                if showToast {
                    Text(toastMessage)
                        .font(.custom("IBMPlexSansKR-Regular", size: 18))
                        .foregroundColor(.white)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 10)
                        .background(.previewGray)
                        .cornerRadius(10)
                }
                Spacer()
                    .frame(height: 20)
            }
        }
        .navigationBarBackButtonHidden(true)

    }
}

#Preview {
    CreatePostView(path: .constant([]))
        .environmentObject(PostViewModel())
}
