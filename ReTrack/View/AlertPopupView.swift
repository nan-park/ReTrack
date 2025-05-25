import SwiftUI

struct AlertPopupView: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @Binding var isShowingAlert: Bool
    @Binding var isShowingDeleteAlert: Bool
    @Binding var inputPassword: String
    let id: UUID
    @Binding var buttonType: String
    @State var showToast: Bool = false
    @Binding var path: [ViewType]
    
    var body: some View {
        if let post = postViewModel.posts.first(where: { $0.id == id }){
            VStack(spacing: 0) {
                Text("비밀번호를 입력하세요")
                    .font(.custom("IBMPlexSansKR-Bold", size: 17))
                    .padding(.vertical, 20)

                // password input
                SecureField("비밀번호", text: $inputPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
                    .font(.custom("IBMPlexSansnKR-Regular", size: 15))
                    .padding(.bottom)
                Rectangle()
                    .foregroundColor(.dividerGray)
                    .frame(height: 1)
                    .padding(0)
                HStack(spacing: 0) {
                    Spacer()

                    // cancel Button
                    Button {
                        isShowingAlert = false
                        buttonType = ""
                        inputPassword = ""
                    } label: {
                        Text("취소")
                    }
                    Spacer()
                    Rectangle()
                        .foregroundColor(.dividerGray)
                        .frame(width: 1, height: 50)
                        .padding(0)
                    Spacer()

                    // ok Button
                    Button {
                        if post.password == inputPassword {
                            if buttonType == "삭제" {
                                isShowingAlert = false
                                isShowingDeleteAlert = true
                                inputPassword = ""
                            } else if buttonType == "수정" {
                                isShowingAlert = false
                                inputPassword = ""
                                path.append(.editPostView(post: post))
                            }
                        } else {
                            showToast = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                showToast = false
                            }
                        }
                    } label: {
                        Text("확인")
                    }
                    Spacer()
                }

            }
            .background(Color.alertGray)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .frame(width: 265, height: 155)
        }

    }
}

//#Preview {
//    AlertPopupView(isShowingAlert: .constant(true), inputPassword: "", buttonType: .constant("삭제"))
//}
