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
        GeometryReader { geometry in
            VStack {
                ChartView(width: geometry.size.width, height: geometry.size.height)
                    .padding()
//                HStack {
//                    Spacer()
//                    RaspberryPiView()
//                    Spacer()
//                    ControlButtonView()
//                    Spacer()
//                }
                RaspberryPiView()
                ControlButtonView()
                
                HStack {
                    CameraView(width: geometry.size.width, height: geometry.size.height)
                        .offset(y: -50)
                    Spacer()
                    
                }
                
                
                //            Spacer()
                //                .padding(.top, 40)
                //                .padding()
                //            AttitudeIndicatorView(motionManager: motionManager)
                //                .border(.green)
                
                //            HStack {
                //                Text("haha")
                //                VStack{
                //                    Text("haha")
                //                    Text("haha")
                ////                    RaspberryPiView()
                ////                    ControlButtonView()
                //                }
                ////                CameraView()
                //            }
                //            Spacer()
                
            }
        }
//        .environmentObject(recordAllDataManager)
    }
    }

#Preview(traits: .landscapeRight) {
    PanelView()
        .environmentObject(RecordAllDataModel())
        .environmentObject(MotionManager.shared)
        .environmentObject(CameraManager.shared)
        .environmentObject(WebSocketManager.shared)
}

