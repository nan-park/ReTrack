import Foundation
import UIKit

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    private let service = PostService()
    @Published var displayedCount: Int = 5
    @Published var isLoading: Bool = false

    var sortedPosts: [Post] {
        posts.sorted { $0.createdAt > $1.createdAt }
    }

    var displayedPosts: [Post] {
        Array(sortedPosts.prefix(displayedCount))
    }

    init() {
        loadPosts()
    }

    func loadPosts() {
        self.isLoading = true
        service.fetchAll { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loadedPosts):
                    self.posts = loadedPosts
                case .failure(let error):
                    print("❌ 불러오기 실패: \(error)")
                }
                self.isLoading = false
            }
        }
    }

    func deletePost(id: UUID) {
        service.delete(id: id) { result in
            if case .success = result {
                DispatchQueue.main.async {
                    self.posts.removeAll { $0.id == id }
                }
            }
        }
    }


    func checkCondition(
        _ nickname: String, _ content: String, _ password: String,
        _ passwordConfirm: String
    ) -> String {
        if nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "닉네임을 입력해주세요"
        } else if content.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        {
            return "내용을 입력해주세요"
        } else if password != passwordConfirm {
            return "비밀번호가 일치하지 않습니다"
        } else if password.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        {
            return "비밀번호를 입력하세요"
        } else {
            return ""
        }
    }

    func addPostWithImages(
        nickname: String,
        password: String,
        content: String,
        images: [UIImage]
    ) {
        self.isLoading = true // (1) 업로드 시작할 때 true
        service.uploadImages(images: images) { result in
            switch result {
            case .success(let urls):
                let newPost = Post(
                    id: UUID(),
                    nickname: nickname,
                    password: password,
                    content: content,
                    imageUrls: urls,
                    createdAt: Date()
                )
                DispatchQueue.main.async {
                    self.posts.insert(newPost, at: 0)
                    self.isLoading = false // (2) 로컬 반영 후 바로 false
                }
                self.service.create(post: newPost) { result in
                    if case .failure = result {
                        // 실패 시 롤백
                        DispatchQueue.main.async {
                            self.posts.removeAll { $0.id == newPost.id }
                            // 필요하다면 에러 알림 등 추가
                        }
                    }
                    // 성공 시 별도 처리 필요 없음
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false // (3) 업로드 실패 시도 false
                }
                print("❌ 이미지 업로드 실패: \(error.localizedDescription)")
            }
        }
    }



    func updatePostWithImages(
        id: UUID,
        nickname: String,
        content: String,
        images: [UIImage]
    ) {
        // ✅ 기존 게시물 찾기
        guard let originalPost = posts.first(where: { $0.id == id }) else {
            print("❌ 기존 게시물을 찾을 수 없습니다.")
            return
        }

        // ✅ 새 이미지 업로드
        service.uploadImages(images: images) { result in
            switch result {
            case .success(let urls):
                let updatedPost = Post(
                    id: id,
                    nickname: nickname,
                    password: originalPost.password,
                    content: content,
                    imageUrls: urls,  // ✅ 새 이미지로만 교체
                    createdAt: originalPost.createdAt
                )
                self.service.update(post: updatedPost) { result in
                    if case .success = result {
                        DispatchQueue.main.async {
                            self.loadPosts()
                        }
                    }
                }

            case .failure(let error):
                print("❌ 이미지 업로드 실패: \(error.localizedDescription)")
            }
        }
    }

    func updatePostWithImageUrls(id: UUID, content: String, imageUrls: [String]) {
        guard let originalPost = posts.first(where: { $0.id == id }) else {
            print("❌ 기존 게시물을 찾을 수 없습니다.")
            return
        }
        
        let updatedPost = Post(
            id: id,
            nickname: originalPost.nickname,
            password: originalPost.password,
            content: content,
            imageUrls: imageUrls,
            createdAt: originalPost.createdAt
        )
        self.service.update(post: updatedPost) {result in
            if case .success = result {
                DispatchQueue.main.async {
                    self.loadPosts()
                }
            }
        }
        

    }

}
