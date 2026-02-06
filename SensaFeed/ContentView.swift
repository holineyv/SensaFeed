//
//  ContentView.swift
//  SensaFeed
//
//  Created by Vasyl Holiney on 06/02/2026.
//

import SwiftUI

enum AppTab: Hashable {
    case feeds
    case chat
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .feeds

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Feeds", systemImage: "newspaper", value: .feeds) {
                FeedListView()
            }

            Tab("Chat", systemImage: "sparkles", value: .chat) {
                ChatView()
            }
        }
        .onChange(of: selectedTab) {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    ContentView()
        .environment(FeedService())
        .environment(ChatService())
}
