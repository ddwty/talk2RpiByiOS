//
//  AttitudeIndicatorView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/19/24.
//
import SwiftUI

struct AttitudeIndicatorView: View {
    @ObservedObject var motionManager: MotionManager3
    let textWidth = CGFloat(50)
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Text("Quaternion")
                    .font(.headline)
                    .padding(.top)
                HStack(spacing: 10.0) {
                    Text("x:\(motionManager.motionData.quaternion.x, specifier: "%.1f")")
                        .foregroundStyle(.red)
                        .frame(minWidth: textWidth, alignment: .leading)
                    Text("y:\(motionManager.motionData.quaternion.y, specifier: "%.1f")")
                        .foregroundStyle(.green)
                        .frame(minWidth: textWidth, alignment: .leading)
                    Text("z:\(motionManager.motionData.quaternion.z, specifier: "%.1f")")
                        .foregroundStyle(.blue)
                        .frame(minWidth: textWidth, alignment: .leading)
                    Text("w:\(motionManager.motionData.quaternion.w, specifier: "%.1f")")
                        .frame(minWidth: textWidth, alignment: .leading)
                }
                
//                Spacer()
            }
            .padding(.bottom)
            .padding(.horizontal)
            .frame(width: 250)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(15)
            
            Spacer()
            AttitudeVisualizer(
                pitch: motionManager.motionData.attitude.pitchDegrees,
                roll: motionManager.motionData.attitude.rollDegrees,
                yaw: motionManager.motionData.attitude.yawDegrees
            )
//            .border(.blue)
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 80, height: 80)
            .offset(y: 10)
            
            Spacer()
            
            VStack {
                Text("Acceleration")
                    .font(.headline)
                    .padding(.top)
                HStack(spacing: 10.0) {
                    Text("x:\(motionManager.motionData.acceleration.x, specifier: "%.1f")")
                        .foregroundStyle(.red)
                        .frame(width: textWidth, alignment: .leading)
                    Text("y:\(motionManager.motionData.acceleration.y, specifier: "%.1f")")
                        .foregroundStyle(.green)
                        .frame(width: textWidth, alignment: .leading)
                    Text("z:\(motionManager.motionData.acceleration.z, specifier: "%.1f")")
                        .foregroundStyle(.blue)
                        .frame(width: textWidth, alignment: .leading)
                }
//                Spacer()
            }
            .padding(.bottom)
            .padding(.horizontal)
            .frame(width: 250)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(15)
            
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
                ZStack {
                    // Background cross
                    Path { path in
                        // y
                        path.move(to: CGPoint(x: halfSize, y: 0))
                        path.addLine(to: CGPoint(x: halfSize, y: size))
                        
                        // x
                        path.move(to: CGPoint(x: 0, y: halfSize))
                        path.addLine(to: CGPoint(x: size, y: halfSize))
                    }
                    .stroke(Color.gray, lineWidth: 1.5)
                    
                    
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
                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)
//                .border(.green)
                
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    AttitudeIndicatorView(motionManager: MotionManager3())
}


