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
            motionManager.startUpdates()
            cameraManager.startRecording()
            webSocketManager.startRecordingForceData()
            webSocketManager.isRecording = true

            isRecording = true
        }

        func stopRecordingData() {
            guard isRecording else { return }

//            motionManager.stopUpdates()
            cameraManager.stopRecording()

            recordedMotionData = motionManager.motionDataArray
            recordedForceData = webSocketManager.forceData
            print("Recorded force data length: \(recordedForceData.count)")
            print("Force data:\(recordedForceData)")
            print("Force data:\(webSocketManager.forceData)")

            isRecording = false
        }
    
}

extension RecordAllDataModel {
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            self.recordingDuration = Date().timeIntervalSince(startTime)
        }
    }
}
