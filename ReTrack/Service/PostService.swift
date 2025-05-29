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

    func uploadImages(images: [UIImage], completion: @escaping (Result<[String], Error>) -> Void) {
        let storage = Storage.storage()
        let folder = "post_images"
        var uploadedURLs: [String] = []
        let dispatchGroup = DispatchGroup()
        var uploadError: Error?

        guard !images.isEmpty else {
            completion(.success([]))
            return
        }

        for image in images {
            let resizedImage = image.resized(to: 1024) ?? image
            guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
                completion(.failure(NSError(domain: "ImageEncodingError", code: -1)))
                return
            }

            dispatchGroup.enter()
            let filename = UUID().uuidString + ".jpg"
            let ref = storage.reference().child(folder).child(filename)

            ref.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    uploadError = error
                    dispatchGroup.leave()
                    return
                }
                ref.downloadURL { url, error in
                    if let url = url {
                        uploadedURLs.append(url.absoluteString)
                    } else if let error = error {
                        uploadError = error
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            if let error = uploadError {
                completion(.failure(error))
            } else {
                completion(.success(uploadedURLs))
            }
        }
    }
    
    
}
