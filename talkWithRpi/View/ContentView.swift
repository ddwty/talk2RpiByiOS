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
//            PureUsbView()
//                .tabItem {
//                    Label("Via USB", systemImage: "cable.connector")
//                }
//            RaspberryPiView()
//                .tabItem {
//                    Label("Via wifi", systemImage: "network")
//                }
//            PureUsbImgView()
//                .tabItem {
//                    Label("Img", systemImage: "photo")
//                }
//            ForTCP_Server()
//                .tabItem {
//                    Label("ForTCP_Server", systemImage: "person")
//                }
//            AttitudeIndicatorView()
//                .tabItem {
//                    Text("AttitudeIndicator" )
//                }
//            CameraView()
//                .tabItem {
//                    Text("Camera" )
//                }
            
//            TestWebsocket()
//                .tabItem {
//                    Text("TestWebsocket" )
//                }
//            TESTView()
//                .tabItem {
//                    Text("加速度" )
//                }
//           ChartView()
//                .tabItem {
//                    Text("图" )
//                }
//            ScrollView {
                PanelView()
//            }
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
            MyARView()
                .tabItem {
                    Label("AR",systemImage: "clock")
                }
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
