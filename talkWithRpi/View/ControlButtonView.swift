//
//  ControlButtonView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/23/24.
//

import SwiftUI

struct ControlButtonView: View {
    @EnvironmentObject var recordAllDataModel: RecordAllDataModel
//    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var webSocketManager: WebSocketManager
//    @EnvironmentObject var arRecorder: ARRecorder
    
    @State var isRunningTimer = false
    
    @State private var startTime = Date()
    @State private var display = "00:00:00"
    @State private var timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
//            Image(systemName: "wifi.router")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 60, height: 60)
//                .symbolEffect(.variableColor.iterative.reversing, isActive: Bool)
          
            Button(action: {
                withAnimation {
                    if isRunningTimer {
                        recordAllDataModel.stopRecordingData()
                        timer.upstream.connect().cancel()
                        self.isRunningTimer = false
                    } else {
                        recordAllDataModel.startRecordingData()
                        display = "00:00:00"
                        startTime = Date()
                        timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
                        self.isRunningTimer = true
                    }
                }
            }) {
                HStack {
                    if isRunningTimer {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
//                            .symbolVariant(.fill.circle)
                            .foregroundColor(.white)
                            .symbolEffect(.pulse.wholeSymbol)
                           
                        Text(display)
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.white)
//                            .frame(width: 80, alignment: .leading)
                    } else {
                        Text("Start Recording")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
//                .frame(width: 180, height: 30)
                .frame(height: 25)
                .padding()
                .background(webSocketManager.connected ? (isRunningTimer ? Color.red : Color.green) : Color.gray)
                .clipShape(Capsule())
                
//                .shadow(color: .green, radius: 5)
            }
            .disabled(webSocketManager.connected == false)
            .onReceive(timer) { _ in
                if isRunningTimer {
                    let duration = Date().timeIntervalSince(startTime)
                    let minutes = Int(duration) / 60
                    let seconds = Int(duration) % 60
                    let milliseconds = Int((duration - Double(minutes * 60 + seconds)) * 100) % 100
                    display = String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
                }
            }
            .onAppear {
                timer.upstream.connect().cancel()
            }
        }
    }
}



#Preview(traits: .landscapeRight) {
    ControlButtonView()
        .environmentObject(RecordAllDataModel())
        .environmentObject(MotionManager.shared)
//        .environmentObject(CameraManager.shared)
        .environmentObject(WebSocketManager.shared)
        .environmentObject(ARRecorder.shared)
}
