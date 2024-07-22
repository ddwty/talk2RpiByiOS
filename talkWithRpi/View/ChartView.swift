//
//  ChartView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/18/24.
//


import SwiftUI
import Charts
import CoreMotion

struct ChartView: View {
    @StateObject var motionManager = MotionManager3()
    @State var motionData: [MotionData] = []
    private let attitudeKeys = ["Pitch", "Yaw", "Roll"]
    private let rotationRateKeys = ["xRotationRate", "yRotationRate", "zRotationRate"]
    
    @State var showCharts = false
    @State var isReadingData = false
    
    var body: some View {
            VStack {
                AttitudeIndicatorView(motionManager: motionManager)
                
                HStack {
                    Spacer()
                    
                    Button(action: { self.showCharts.toggle() }) {
                        if showCharts {
                            Text("Close Charts")
                        } else {
                            Text("Show Charts")
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    
//                    Button(action: {
//                        if self.isReadingData {
//                            self.motionManager.stopUpdates()
//                        } else {
//                            self.motionManager.startUpdates()
//                        }
//                        self.isReadingData.toggle()
//                    }) {
//                        if isReadingData {
//                            Text("Stop")
//                        } else {
//                            Text("Start")
//                        }
//                    }
//                    .buttonStyle(.bordered)
                    
                    Button(action: { self.motionManager.resetReferenceFrame() }) {
                        Text("Reset Reference")
                    }
                    .buttonStyle(.bordered)
                    
                    Toggle("Use High Accuracy", isOn: $motionManager.useHighAccuracy)
                }
                .padding()
                
                if showCharts {
                        HStack {
                            VStack {
                                Chart {
                                    ForEach(attitudeKeys, id: \.self) { key in
                                        ForEach(motionData) { data in
                                            LineMark(
                                                x: .value("Time", data.timestamp),
                                                y: .value(key, getAttitudeValue(for: key, from: data))
                                            )
                                            .foregroundStyle(by: .value("Type", key))
                                        }
                                    }
                                }
                                .chartXAxisLabel("Time")
                                .chartYAxisLabel("Value")
                                .frame(height: 200)
                                .chartYScale(domain: -3...3)
                                .padding(5)
                                
                                Chart {
                                    ForEach(rotationRateKeys, id: \.self) { key in
                                        ForEach(motionData) { data in
                                            LineMark(
                                                x: .value("Time", data.timestamp),
                                                y: .value(key, getRotationRateValue(for: key, from: data))
                                            )
                                            .foregroundStyle(by: .value("Type", key))
                                        }
                                    }
                                }
                                .chartXAxisLabel("Time")
                                .chartYAxisLabel("Value")
                                .chartYScale(domain: -3...3)
                                .padding(5)
                            }
                            Spacer()
                        }
                }
                
                Spacer()
            }
            .onAppear {
                self.motionData = motionManager.motionDataArray
                self.motionManager.startUpdates()
            }
            .onReceive(motionManager.$motionDataArray) { newMotionData in
                self.motionData = newMotionData
            }
            .onDisappear {
                self.motionManager.stopUpdates()
            }
        
    }
    
    func getAttitudeValue(for key: String, from data: MotionData) -> Double {
        switch key {
        case "Pitch":
            return data.attitude.pitch
        case "Yaw":
            return data.attitude.yaw
        case "Roll":
            return data.attitude.roll
        default:
            return 0
        }
    }
    
    func getRotationRateValue(for key: String, from data: MotionData) -> Double {
        switch key {
        case "xRotationRate":
            return data.rotationRate.xRotationRate
        case "yRotationRate":
            return data.rotationRate.yRotationRate
        case "zRotationRate":
            return data.rotationRate.zRotationRate
        default:
            return 0
        }
    }
}

#Preview(traits: .landscapeRight) {
    ChartView()
        .previewInterfaceOrientation(.landscapeLeft)
}
