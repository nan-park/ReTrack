//
//  ReTrackApp.swift
//  ReTrack
//
//  Created by 박난 on 4/11/25.
//

import SwiftUI
import Firebase

@main
struct ReTrackApp: App {
    @StateObject var postViewModel: PostViewModel = PostViewModel()
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(postViewModel)
        }
    }
}
