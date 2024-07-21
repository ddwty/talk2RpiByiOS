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
//            ViaWifiView()
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
            TestWebsocket()
                .tabItem {
                    Text("TestWebsocket" )
                }
//            TESTView()
//                .tabItem {
//                    Text("加速度" )
//                }
           ChartView()
                .tabItem {
                    Text("图" )
                }
            
        }
    }
}

#Preview {
    ContentView()
}
