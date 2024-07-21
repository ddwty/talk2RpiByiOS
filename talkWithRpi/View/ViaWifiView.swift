//
//  ViaWifiView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/15/24.
// 使用访问GeS的树莓派

import SwiftUI
import Combine
import Starscream

struct ViaWifiView: View {
    @ObservedObject var webSocketManager = WebSocketManager()
        var body: some View {
            VStack(spacing: 20) {
                Text(webSocketManager.connected ? "Connected" : "Disconnected")
                    .font(.title)
                    .foregroundColor(webSocketManager.connected ? .green : .red)
                Button(action: {webSocketManager.connect()}) {
                    Text("Connect")
                }
                HStack {
                    Button(action: {
                        webSocketManager.calibrateIMU()
                    }) {
                        Text("Calibrate IMU")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        webSocketManager.startRecording()
                        webSocketManager.isRecording = true
                    }) {
                        Text("Start Recording")
                            .font(.headline)
                            .padding()
                            .background(webSocketManager.isRecording ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(webSocketManager.isRecording)
                    }
                    
                    Button(action: {
                        webSocketManager.endRecording()
                        webSocketManager.isRecording = false
                    }) {
                        Text("End Recording")
                            .font(.headline)
                            .padding()
                            .background(webSocketManager.isRecording ? Color.red : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .disabled(!webSocketManager.isRecording)
                    }
                    
                    Button(action: {
                        webSocketManager.downloadData()
                    }) {
                        Text("Download Data")
                            .font(.headline)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                
                if let imuData = webSocketManager.imuData {
                    VStack(alignment: .leading) {
                        Text("IMU Data")
                            .font(.headline)
                        Text("Quat: \(imuData.quat.map { String(format: "%.2f", $0) }.joined(separator: ", "))")
                        Text("Time: \(imuData.time_stamp.secs) secs \(imuData.time_stamp.nanos) nanos")
                    }
                }
                
                if let fingerData = webSocketManager.fingerData {
                    VStack(alignment: .leading) {
                        Text("Finger Force Data")
                            .font(.headline)
                        if let force = fingerData.force {
                            Text("Finger Force: \(force.map { String(format: "%.2f", $0) }.joined(separator: ", "))")
                        }
                        Text("Time: \(fingerData.time_stamp.secs) secs \(fingerData.time_stamp.nanos) nanos")
                    }
                }
                
                if let image = webSocketManager.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 1280, height: 720)
                }
                
                if let time = webSocketManager.time {
                    Text("Time: \(time.secs) secs \(time.nanos) nanos")
                }
            }
            .padding()
        }
}

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ViaWifiView_Previews: PreviewProvider {
    static var previews: some View {
        ViaWifiView()
    }
}
