import SwiftUI

struct DeleteAlertPopupView: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @Binding var isShowingDeleteAlert: Bool
    @Environment(\.dismiss) var dismiss
    @Binding var path: [ViewType]
    let id: UUID
    var body: some View {
        if postViewModel.posts.first(where: { $0.id == id }) != nil {
            VStack(spacing: 0) {
                Text("정말 삭제하시겠습니까?")
                    .font(.custom("IBMPlexSansKR-Bold", size: 17))
                    .padding(.vertical, 20)
                
                Rectangle()
                    .foregroundColor(.dividerGray)
                    .frame(height: 1)
                    .padding(0)
                HStack(spacing: 0) {
                    Spacer()
                    
                    // cancel Button
                    Button {
                        isShowingDeleteAlert = false
                    } label: {
                        Text("취소")
                        
                    }
                    Spacer()
                    Rectangle()
                        .foregroundColor(.dividerGray)
                        .frame(width: 1, height: 50)
                        .padding(0)
                    Spacer()
                    
                    // delete Button
                    Button {
                        postViewModel.deletePost(id: id)
                        path = []
                    } label: {
                        Text("삭제")
                            .foregroundColor(.red)
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
//    DeleteAlertPopupView(isShowingDeleteAlert: .constant(true))
//}
