//
//  ContentView.swift
//  ReTrack
//
//  Created by 박난 on 4/11/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @State var path: [ViewType] = []
    var postID = UUID()  // 임시
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack(spacing: 0) {
                    VStack {
                        HStack {
                            Text("ReTrack")
                                .font(.custom("KleeOne-SemiBold", size: 20))
                            Spacer()
                            Button {
                                path.append(.createPostView)
                                print(path)
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.black)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        Spacer()
                            .frame(height: 9)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.dividerGray)
                        Spacer()
                            .frame(height: 8)
                    }
                    .padding(.horizontal, 32)

                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(
                                Array(postViewModel.sortedPosts), id: \.self
                            ) {
                                post in
                                Button {
                                    path.append(.postDetailView(id: post.id))
                                } label: {
                                    BoxView(id: post.id)
                                        .padding(.horizontal, 32)
                                        .onAppear {
                                            if post
                                                == postViewModel.displayedPosts
                                                .last
                                                && postViewModel.displayedPosts
                                                    .count
                                                    < postViewModel.sortedPosts
                                                    .count
                                            {
                                                postViewModel.displayedCount +=
                                                    5
                                            }
                                        }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                if postViewModel.isLoading {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("변경사항을 불러오는 중...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
            .navigationDestination(for: ViewType.self) { type in
                switch type {
                case .createPostView:
                    CreatePostView(path: $path)
                case let .postDetailView(postID):
                    PostDetailView(path: $path, id: postID)
                case let .editPostView(post):
                    EditPostView(
                        path: $path, post: post,
                        onSave: {
                            originalId, newNickname, newContent, newImages
                            in
                            postViewModel.updatePostWithImages(
                                id: originalId, nickname: newNickname,
                                content: newContent, images: newImages)
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(PostViewModel())
}
