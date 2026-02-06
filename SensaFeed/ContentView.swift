//
//  ContentView.swift
//  SensaFeed
//
//  Created by Vasyl Holiney on 06/02/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        FeedListView()
    }
}

#Preview {
    ContentView()
        .environment(FeedService())
}
