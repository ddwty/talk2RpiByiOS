//
//  talkWithRpiApp.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/13/24.
//

import SwiftUI

@main
struct talkWithRpiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MotionManager.shared)
                .environmentObject(RecordAllDataModel())
        }
    }
}
