//
//  RecordAllDataModel.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/22/24.
// 这里控制所有数据的录制开始/结束/保存

import Foundation
import SwiftUI

class RecordAllDataModel: ObservableObject {
    @Published var isRecording = false
    private let motionManager = MotionManager.shared
    private let cameraManager = CameraManager.shared
    private let webSocketManager = WebSocketManager.shared
    
    private var timer: Timer?
    private var recordingStartTime: Date?
    @Published var recordingDuration: TimeInterval = 0
    
    var recordedMotionData: [MotionData] = []
    var recordedForceData:[ForceData?] = []
    
    
    func startRecordingData() {
            guard !isRecording else { return }
        
            recordedMotionData.removeAll()
            recordedForceData.removeAll()
            print("Start recording")
//            motionManager.startUpdates()
            cameraManager.startRecording()
            webSocketManager.startRecordingForceData()
            webSocketManager.isRecording = true

        recordingStartTime  = Date()
            isRecording = true
        startTimer()
        print(recordedForceData.capacity)
    }

        func stopRecordingData() {
            guard isRecording else { return }

//            motionManager.stopUpdates()
            cameraManager.stopRecording()
            webSocketManager.stopRecordingForceData()
            motionManager.stopRecording()

            recordedMotionData = motionManager.motionDataArray
            recordedForceData = webSocketManager.recordedForceData
            print("Recorded force data length: \(recordedForceData.count)")
            print("Force data:\(recordedForceData)")
            print("Force data:\(webSocketManager.recordedForceData)")

            isRecording = false
            
            stopTimer()
            print(recordedForceData.capacity)
        }
}

extension RecordAllDataModel {
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            self.recordingDuration = Date().timeIntervalSince(startTime)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // mm:ss:ms
    func formattedDuration() -> String {
            let minutes = Int(recordingDuration) / 60
            let seconds = Int(recordingDuration) % 60
            let milliseconds = Int((recordingDuration - TimeInterval(minutes * 60 + seconds)) * 1000)
            return String(format: "%02d:%02d:%2d", minutes, seconds, milliseconds)
        }
    
}
