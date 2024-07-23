//
//  ControlButtonView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/23/24.
//

import SwiftUI

struct ControlButtonView: View {
    @EnvironmentObject var recordAllDataModel: RecordAllDataModel
    @EnvironmentObject var motionManager: MotionManager
    var body: some View {
        VStack {
            // Record Button
            Button(action: {
                self.motionManager.resetReferenceFrame()
            }) {
                Text("Reset Attitude Reference")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            Button(action: {
                if recordAllDataModel.isRecording {
                    recordAllDataModel.stopRecordingData()
                } else {
                    recordAllDataModel.startRecordingData()
                }
            }) {
                Text(recordAllDataModel.isRecording ? "Stop Recording" : "Start Recording")
            }
            .padding()
            .background(recordAllDataModel.isRecording ? Color.red : Color.green)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
        }
    }
}

#Preview(traits: .landscapeRight) {
    ControlButtonView()
        .environmentObject(RecordAllDataModel())
        .environmentObject(MotionManager.shared)
    
}
