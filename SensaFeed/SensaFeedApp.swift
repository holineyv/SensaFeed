//
//  SensaFeedApp.swift
//  SensaFeed
//
//  Created by Vasyl Holiney on 06/02/2026.
//

import SwiftUI

@main
struct SensaFeedApp: App {
    @State private var feedService = FeedService()
    @State private var chatService = ChatService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(feedService)
                .environment(chatService)
        }
    }
}
