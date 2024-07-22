//
//  PanelView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/22/24.
//

import SwiftUI

struct PanelView: View {
    @StateObject var motionManager = MotionManager3()
    @State var motionData: [MotionData] = []
    var body: some View {
        VStack {
            ChartView()
                .padding(.top, 40)
//            AttitudeIndicatorView(motionManager: motionManager)
//                .border(.green)
            HStack {
                ViaWifiView()
                CameraView()
            }
//            Spacer()
            
        }
    }
    }

#Preview(traits: .landscapeRight) {
    PanelView()
}
