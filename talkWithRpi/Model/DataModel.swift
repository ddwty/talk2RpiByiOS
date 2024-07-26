//
//  ForceDataModel.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/23/24.
//

import Foundation
import ARKit
import simd
import SwiftData

struct ForceData {
    let timeStamp: String
    let forceData:[Double]?
}

struct AngleData {
    let timeStamp: String
    let angle: Int
}



//struct FrameData {
//    let timestamp: Double
//    let cameraTransform: simd_float4x4
//}

//struct ARFrameData: Codable {
//    let timestamp: Double
//    let cameraTransform: simd_float4x4
//    
//    init(timestamp: Double, cameraTransform: simd_float4x4) {
//        self.timestamp = timestamp
//        self.cameraTransform = cameraTransform
//    }
//    
//    private enum CodingKeys: String, CodingKey {
//        case timestamp
//        case cameraTransform
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        timestamp = try container.decode(Double.self, forKey: .timestamp)
//        
//        let transformArray = try container.decode([Float].self, forKey: .cameraTransform)
//        guard transformArray.count == 16 else {
//            throw DecodingError.dataCorruptedError(forKey: .cameraTransform, in: container, debugDescription: "Invalid matrix size")
//        }
//        
//        cameraTransform = simd_float4x4(columns: (
//            SIMD4<Float>(transformArray[0], transformArray[1], transformArray[2], transformArray[3]),
//            SIMD4<Float>(transformArray[4], transformArray[5], transformArray[6], transformArray[7]),
//            SIMD4<Float>(transformArray[8], transformArray[9], transformArray[10], transformArray[11]),
//            SIMD4<Float>(transformArray[12], transformArray[13], transformArray[14], transformArray[15])
//        ))
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(timestamp, forKey: .timestamp)
//        
//        let transformArray = [
//            cameraTransform.columns.0.x, cameraTransform.columns.0.y, cameraTransform.columns.0.z, cameraTransform.columns.0.w,
//            cameraTransform.columns.1.x, cameraTransform.columns.1.y, cameraTransform.columns.1.z, cameraTransform.columns.1.w,
//            cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z, cameraTransform.columns.2.w,
//            cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z, cameraTransform.columns.3.w
//        ]
//        
//        try container.encode(transformArray, forKey: .cameraTransform)
//    }
//}

//struct ARData {
//    let timestamp: Double
//    let transform: simd_float4x4
//}
@Model
class ARData: ObservableObject {
    var timestamp: Double
    var transform: [Float] // 使用数组来存储矩阵数据
    
    init(timestamp: Double, transform: simd_float4x4) {
        self.timestamp = timestamp
        self.transform = ARData.convertSimdToArray(transform)
    }
    
    static func convertSimdToArray(_ transform: simd_float4x4) -> [Float] {
        return [
            transform.columns.0.x, transform.columns.0.y, transform.columns.0.z, transform.columns.0.w,
            transform.columns.1.x, transform.columns.1.y, transform.columns.1.z, transform.columns.1.w,
            transform.columns.2.x, transform.columns.2.y, transform.columns.2.z, transform.columns.2.w,
            transform.columns.3.x, transform.columns.3.y, transform.columns.3.z, transform.columns.3.w
        ]
    }
    
    static func convertArrayToSimd(_ array: [Float]) -> simd_float4x4 {
        precondition(array.count == 16, "Array must contain exactly 16 elements")
        return simd_float4x4(
            simd_float4(array[0], array[1], array[2], array[3]),
            simd_float4(array[4], array[5], array[6], array[7]),
            simd_float4(array[8], array[9], array[10], array[11]),
            simd_float4(array[12], array[13], array[14], array[15])
        )
    }
}
