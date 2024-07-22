//
//  CameraView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/21/24.
//

import SwiftUI
import AVFoundation
import Photos

struct CameraView: View {
    @StateObject private var cameraManager = CameraManager()
        var body: some View {
            VStack {
                Text("Recording: \(Int(cameraManager.recordingDuration)) seconds")
                    .font(.headline)
//                    .padding()
                Button(action: {
                        if cameraManager.isRecording {
                            cameraManager.stopRecording()
                        } else {
                            cameraManager.startRecording()
                        }
                }) {
                    Text(cameraManager.isRecording ? "Stop Recording" : "Start Recording")
                        .padding()
                        .background(cameraManager.isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
//                .padding()
                
                
                if let session = cameraManager.captureSession {
                    CameraPreviewView(session: session)
                        .frame(width: UIScreen.main.bounds.width * 0.1 * 4 / 3, height: UIScreen.main.bounds.width * 0.1)
                                    .cornerRadius(8)
//                                    .padding()
                }
            }
            .onAppear {
                PHPhotoLibrary.requestAuthorization { status in
                    if status != .authorized {
                        print("Permission to access photo library not granted.")
                    }
                }
               
            }
        }
}




#Preview(traits: .landscapeRight) {
    CameraView()
}
