//
//  TESTVIEW.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/17/24.
// 测试加速度计最大频率

import SwiftUI
import CoreMotion

struct TESTView: View {
    @StateObject private var motionManager = MotionManager2()
        @State private var isTesting = false
        
        var body: some View {
            VStack {
                Text("Accelerometer Maximum Frequency Test")
                    .font(.title)
                    .padding()
                
                if let maxFrequency = motionManager.maxFrequency {
                    Text("Max Frequency: \(maxFrequency, specifier: "%.2f") Hz")
                        .font(.largeTitle)
                        .padding()
                } else {
                    Text("Press 'Start Testing' to begin")
                        .font(.largeTitle)
                        .padding()
                }
                
                Button(action: {
                    motionManager.startAccelerometers()
                    isTesting = true
                }) {
                    Text(isTesting ? "Retest" : "Start Testing")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .onDisappear {
                motionManager.stopAccelerometers()
            }
        }
}

class MotionManager: ObservableObject {
        private let motion = CMMotionManager()
        private var timer: Timer?
        private var startTime: Date?
        private var dataCount: Int = 0
        @Published var maxFrequency: Double?
        
        func startAccelerometers() {
            if motion.isAccelerometerAvailable {
                motion.accelerometerUpdateInterval = 1.0 / 1000.0 // Set a high frequency
                motion.startAccelerometerUpdates()
                
                startTime = Date()
                dataCount = 0
                maxFrequency = nil
                
                // Reset timer to avoid old timer issue
                timer?.invalidate()
                
                timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
                    guard let self = self else { return }
                    
                    if let startTime = self.startTime {
                        let elapsedTime = Date().timeIntervalSince(startTime)
                        self.maxFrequency = Double(self.dataCount) / elapsedTime
                        self.stopAccelerometers()
                    }
                }
                
                // Collect data as fast as possible
                let dataQueue = OperationQueue()
                dataQueue.maxConcurrentOperationCount = 1
                
                motion.startAccelerometerUpdates(to: dataQueue) { [weak self] data, error in
                    guard let self = self else { return }
                    if data != nil {
                        self.dataCount += 1
                    }
                }
            }
        }
        
        func stopAccelerometers() {
            motion.stopAccelerometerUpdates()
            timer?.invalidate()
            timer = nil
        }
}

class MotionManager2: ObservableObject {
    private let motion = CMMotionManager()
        private var timer: Timer?
        private var startTime: Date?
        private var dataCount: Int = 0
        @Published var maxFrequency: Double?
        
        func startAccelerometers() {
            if motion.isAccelerometerAvailable {
                motion.accelerometerUpdateInterval = 1.0 / 50.0 // Set a high frequency
                startTime = Date()
                dataCount = 0
                maxFrequency = nil
                
                // Reset timer to avoid old timer issue
                timer?.invalidate()
                
                // Create a high-priority operation queue
                let dataQueue = OperationQueue()
                dataQueue.qualityOfService = .userInitiated
                
                motion.startAccelerometerUpdates(to: dataQueue) { [weak self] data, error in
                    guard let self = self else { return }
                    if let data = data {
                        self.dataCount += 1
                    }
                }
                
                // Stop updates after 1 second and calculate frequency
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
                    guard let self = self else { return }
                    
                    if let startTime = self.startTime {
                        let elapsedTime = Date().timeIntervalSince(startTime)
                        self.maxFrequency = Double(self.dataCount) / elapsedTime
                        self.stopAccelerometers()
                    }
                }
            }
        }
        
        func stopAccelerometers() {
            motion.stopAccelerometerUpdates()
            timer?.invalidate()
            timer = nil
        }
}




struct TEXTView_Previews: PreviewProvider {
  static var previews: some View {
    TESTView()
  }
}
