//
//  ContentView.swift
//  SensaFeed
//
//  Created by Vasyl Holiney on 06/02/2026.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case feeds = "Feeds"
    case chat = "AI"
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .feeds

    var body: some View {
        NavigationStack {
            Group {
                switch selectedTab {
                case .feeds:
                    FeedListContent()
                case .chat:
                    ChatContent()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("", selection: $selectedTab) {
                        ForEach(AppTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
            }
            .onChange(of: selectedTab) {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(FeedService())
        .environment(ChatService())
}
