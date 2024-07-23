//
//  PanelView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/22/24.
//

import SwiftUI

struct PanelView: View {
//    @StateObject var motionManager = MotionManager()
    @EnvironmentObject var motionManager: MotionManager
    
    @State var motionData: [MotionData] = []
//    @StateObject var recordAllDataManager = RecordAllDataModel()
    
    var body: some View {
        VStack {
            ChartView()
//                .padding(.top, 40)
                .padding()
//            AttitudeIndicatorView(motionManager: motionManager)
//                .border(.green)
            HStack {
                VStack{
                    RaspberryPiView()
                    ControlButtonView()
                }
                CameraView()
            }
//            Spacer()
            
        }
//        .environmentObject(recordAllDataManager)
    }
    }

#Preview(traits: .landscapeRight) {
    PanelView()
        .environmentObject(RecordAllDataModel())
        .environmentObject(MotionManager.shared)
}

