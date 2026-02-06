//
//  ContentView.swift
//  SensaFeed
//
//  Created by Vasyl Holiney on 06/02/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Feeds", systemImage: "newspaper") {
                FeedListView()
            }

            Tab("Chat", systemImage: "sparkles") {
                ChatView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(FeedService())
        .environment(ChatService())
}
