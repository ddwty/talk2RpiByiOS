//
//  talkWithRpiApp.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/13/24.
//

import SwiftUI
import SwiftData

@main
struct talkWithRpiApp: App {
    @StateObject private var recordAllDataModel = RecordAllDataModel()
   
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MotionManager.shared)
                .environmentObject(recordAllDataModel)
//                .environmentObject(CameraManager.shared)
                .environmentObject(WebSocketManager.shared)
                .environmentObject(ARRecorder.shared)
                .modelContainer(for: ARStorgeData.self)
        }
    }
}
