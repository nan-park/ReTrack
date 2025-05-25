//import SwiftUI
//
//final class PostService {
//    private let key = "savedPosts"
//
//    func loadPosts() -> [UUID: Post] {
//        guard let savedData = UserDefaults.standard.data(forKey: key),
//              let decodedData = try? JSONDecoder().decode([UUID: Post].self, from: savedData) else {
//            return [:]
//        }
//        return decodedData
//    }
//
//    private func savePosts(_ posts: [UUID: Post]){
//        if let encodedData = try? JSONEncoder().encode(posts) {
//            UserDefaults.standard.set(encodedData, forKey: key)
//        }
//    }
//
//    func addPost(posts: inout [UUID: Post], nickname: String, content: String, password: String, imageUrl: [URL]) {
//        let newPost = Post(
//            id: UUID(),
//            nickname: nickname,
//            password: password,
//            content: content,
//            imageUrl: imageUrl,
//            createdAt: Date()
//        )
//        posts[newPost.id] = newPost
//        savePosts(posts)
//    }
//
//    func deletePost(posts: inout [UUID: Post], id: UUID) {
//        posts[id] = nil
//        savePosts(posts)
//    }
//
//    func updatePost(posts: inout [UUID: Post], id: UUID, content: String) {
//        if var post = posts[id] {
//            post.content = content
//            posts[id] = post
//            savePosts(posts)
//        }
//    }
//}
//

import FirebaseFirestore
import FirebaseStorage
import UIKit

final class PostService {
    private let db = Firestore.firestore()
    private let collection = "posts"

    func fetchAll(completion: @escaping (Result<[Post], Error>) -> Void) {
        db.collection(collection)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                do {
                    let posts =
                        try snapshot?.documents.compactMap {
                            try $0.data(as: Post.self)
                        } ?? []
                    completion(.success(posts))
                } catch {
                    completion(.failure(error))
                }
            }
    }

    func create(post: Post, completion: @escaping (Result<Void, Error>) -> Void)
    {
        do {
            try db.collection(collection)
                .document(post.id.uuidString)
                .setData(from: post, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }

    func update(post: Post, completion: @escaping (Result<Void, Error>) -> Void)
    {
        create(post: post, completion: completion)  // Firestore에서 setData로 update 가능
    }

    func delete(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(collection)
            .document(id.uuidString)
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func uploadImages(
        _ images: [UIImage],
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let storage = Storage.storage()
        let folder = "post_images"
        var uploadedURLs: [String] = []
        var remaining = images.count

        guard !images.isEmpty else {
            completion(.success([]))
            return
        }

        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                completion(
                    .failure(NSError(domain: "ImageEncodingError", code: -1)))
                return
            }

            let filename = UUID().uuidString + ".jpg"
            let ref = storage.reference().child(folder).child(filename)

            ref.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                ref.downloadURL { url, error in
                    if let url = url {
                        uploadedURLs.append(url.absoluteString)
                    }
                    remaining -= 1
                    if remaining == 0 {
                        completion(.success(uploadedURLs))
                    }
                }
            }
        }
    }
    
    
}
