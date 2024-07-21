//
//  AttitudeIndicatorView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/19/24.
//
import SwiftUI

struct AttitudeIndicatorView: View {
    @ObservedObject var motionManager: MotionManager3
    
    var body: some View {
        HStack(alignment: .top) {
            AttitudeVisualizer(pitch: motionManager.motionData.attitude.pitchDegrees,
                               roll: motionManager.motionData.attitude.rollDegrees, yaw: motionManager.motionData.attitude.yawDegrees)
            .frame(width: 100, height: 100)
            .padding()
            
            VStack(alignment: .leading) {
                Text("Pitch: \(motionManager.motionData.attitude.pitchDegrees, specifier: "%.2f")°")
                Text("Yaw: \(motionManager.motionData.attitude.yawDegrees, specifier: "%.2f")°")
                Text("Roll: \(motionManager.motionData.attitude.rollDegrees, specifier: "%.2f")°")
            }
            .frame(width: 130, height: 100)
            
            
            VStack {
                Text("Rotation Matrix:")
                    .font(.headline)
                    .padding(.top)
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(motionManager.motionData.rotationMatrix.m11, specifier: "%.2f")")
                        Text("\(motionManager.motionData.rotationMatrix.m21, specifier: "%.2f")")
                        Text("\(motionManager.motionData.rotationMatrix.m31, specifier: "%.2f")")
                    }
                    VStack(alignment: .leading) {
                        Text("\(motionManager.motionData.rotationMatrix.m12, specifier: "%.2f")")
                        Text("\(motionManager.motionData.rotationMatrix.m22, specifier: "%.2f")")
                        Text("\(motionManager.motionData.rotationMatrix.m32, specifier: "%.2f")")
                    }
                    VStack(alignment: .leading) {
                        Text("\(motionManager.motionData.rotationMatrix.m13, specifier: "%.2f")")
                        Text("\(motionManager.motionData.rotationMatrix.m23, specifier: "%.2f")")
                        Text("\(motionManager.motionData.rotationMatrix.m33, specifier: "%.2f")")
                    }
                }
            }
            .frame(width: 130, height: 100)
            VStack {
                Text("Quaternion:")
                    .font(.headline)
                    .padding(.top)
                VStack(alignment: .leading) {
                    Text("x:\(motionManager.motionData.quaternion.x, specifier: "%.2f")")
                    Text("y:\(motionManager.motionData.quaternion.y, specifier: "%.2f")")
                    Text("z:\(motionManager.motionData.quaternion.z, specifier: "%.2f")")
                    Text("w:\(motionManager.motionData.quaternion.w, specifier: "%.2f")")
                }
            }
            .frame(width: 130, height: 100)
            
            VStack {
                Text("Acceleration:")
                    .font(.headline)
                    .padding(.top)
                VStack(alignment: .leading) {
                    Text("x:\(motionManager.motionData.acceleration.x, specifier: "%.2f")")
                    Text("y:\(motionManager.motionData.acceleration.y, specifier: "%.2f")")
                    Text("z:\(motionManager.motionData.acceleration.z, specifier: "%.2f")")
                }
            }
            
        } //:HStcak
        .padding()
    }
}

struct AttitudeVisualizer: View {
    var pitch: Double
    var roll: Double
    var yaw: Double
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let halfSize = size / 2
//            let maxOffset = halfSize  // 限制最大偏移量
            
            VStack {
                Text("pitch: \(pitch)")
                    .font(.footnote)
                Text("size: \(size)")
                    .font(.footnote)
                    
                ZStack {
                    // Background cross
                    Path { path in
                        path.move(to: CGPoint(x: halfSize, y: 0))
                        path.addLine(to: CGPoint(x: halfSize, y: size))
                        path.move(to: CGPoint(x: 0, y: halfSize))
                        path.addLine(to: CGPoint(x: size, y: halfSize))
                    }
                    .stroke(Color.gray, lineWidth: 1.5)
                    
                    // Movable circles for pitch
                    Circle()
                        .fill(Color.red)
                        .frame(width: size * 0.1, height: size * 0.1)
                        .offset(x: CGFloat(pitch * halfSize / 90 ), y: CGFloat(0))
                    Circle()
                        .fill(Color.green)
                        .frame(width: size * 0.1, height: size * 0.1)
                        .offset(x: CGFloat(0), y: CGFloat(-roll * halfSize / 90 ))
                    
                    // Yaw arc
                    Path { path in
                        let startAngle = Angle(degrees: 180)
                        let endAngle = Angle(degrees: 0)
                        path.addArc(center: CGPoint(x: halfSize, y: halfSize - 10), radius: halfSize, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    }
                    .stroke(Color.gray, lineWidth: 1.5)
                    
                    
                    let angle = Angle(degrees: yaw)
                    let radius = halfSize
                    let yOffset = -cos(angle.radians) * radius - 10
                    let xOffset = -sin(angle.radians) * radius
                    
                    Circle() 
                        .fill(Color.blue)
                        .frame(width: size * 0.1, height: size * 0.1)
                        .offset(x: CGFloat(xOffset), y: CGFloat(yOffset))
                    // Yaw
//                    Path { path in
//                        let angle = Angle(degrees: yaw)
//                        let radius = halfSize
//                        let xOffset = -sin(angle.radians) * radius
//                        let yOffset = -cos(angle.radians) * radius
//                        
//                        path.move(to: CGPoint(x: halfSize + xOffset, y: halfSize + yOffset))
//                        path.addLine(to: CGPoint(x: halfSize + xOffset + 10, y: halfSize + yOffset))
//                        path.addLine(to: CGPoint(x: halfSize + xOffset, y: halfSize + yOffset - 10))
//                        path.closeSubpath()
//                    }
//                    .fill(Color.green)
                    
                    // Yaw indicator label
                    //                Text("Yaw: \(yaw, specifier: "%.1f")°")
                    //                    .font(.system(size: 14))
                    //                    .foregroundColor(.green)
                    //                    .offset(y: -halfSize * 0.9)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    AttitudeIndicatorView(motionManager: MotionManager3())
}
