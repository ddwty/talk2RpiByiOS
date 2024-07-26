//
//  ContentView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            PanelView()
            .tabItem {
                Label("Panel", systemImage: "record.circle" )
            }
            SettingView()
                .tabItem {
                    Label("Settings",systemImage: "gear")
                }
            HistoryView()
                .tabItem {
                    Label("History",systemImage: "clock")
                }
           
//            MyARView()
//                .tabItem {
//                    Label("AR",systemImage: "clock")
//                }
        }
    }
}

#Preview(traits: .landscapeRight) {
    ContentView()
        .environmentObject(MotionManager.shared)
        .environmentObject(RecordAllDataModel())
//        .environmentObject(CameraManager.shared)
        .environmentObject(WebSocketManager.shared)
        .environmentObject(ARRecorder.shared)
}
