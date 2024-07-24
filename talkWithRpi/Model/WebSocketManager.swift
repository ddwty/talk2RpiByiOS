//
//  WebSocketManager.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/17/24.
//

import Foundation
import Starscream
import UIKit

struct TimeStamp: Codable {
    let secs: Int
    let nanos: Int
}

struct Force: Codable {
    let value: [Double]?
}

struct ImuData: Codable {
    let quat: [Double]
    let time_stamp: TimeStamp
}

struct FingerFource: Codable {
    let force: Force?
    let time_stamp: TimeStamp
}

class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()
    @Published var recordedForceData: [ForceData] = []  //用于储存
    @Published var imuData: ImuData?
    @Published var time: TimeStamp?
    //    @Published var connected = false {
    //            didSet {
    //                if connected {
    //                    pingTimer?.invalidate()
    //                } else if shouldPing {
    //                    startPingTimer()
    //                }
    //            }
    //        }
    @Published var connected = false
    @Published var isRecording = false
    @Published var image: UIImage?
    @Published var hostName: String = "raspberrypi.local"
    @Published var receivedMessage: String = ""
    
    private var imuSocket: WebSocket?
    private var videoSocket: WebSocket?
    private var leftFingerSocket: WebSocket?
    private var pingTimer: Timer?
    private var shouldPing: Bool = true
    
    
    
    
    //    private var socket: WebSocket?
    private init() {
        
        //        pingServer()
        
//        startPingTimer()
        connectToServer()
        connectLeftFinger()
        
        //        var request = URLRequest(url: URL(string: "ws://\(self.hostName)")!)
        //        request.timeoutInterval = 5
        //        socket = WebSocket(request: request)
        //        socket?.delegate = self
    }
    private func startPingTimer() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.pingServer()
        }
    }
    
    func pingServer() {
        //        guard shouldPing else { return }
        //            guard !connected else { return }
        guard let url = URL(string: "http://\(self.hostName):8080/ping") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    self.connected = (httpResponse.statusCode == 200)
                    if self.connected {
                        print("Connected \(Date())")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.connected = false
                }
            }
        }.resume()
    }
    
    func connectToServer() {
        startPingTimer()
        if self.connected {
            connectLeftFinger()
        }
    }
    
    func reConnectToServer() {
        shouldPing = true
        pingServer()
    }
    
    func disconnect() {
        shouldPing = false
        connected = false
        imuSocket?.disconnect()
        videoSocket?.disconnect()
        leftFingerSocket?.disconnect()
    }
    
    func connectLeftFinger() {
        let fingerRequest = URLRequest(url: URL(string: "ws://\(self.hostName):8080/left_finger/force")!)
        leftFingerSocket = WebSocket(request: fingerRequest)
        leftFingerSocket?.delegate = self
        leftFingerSocket?.connect()
    }
    
    func startRecordingForceData() {
        recordedForceData.removeAll()
        recordedForceData.reserveCapacity(10000)
        isRecording = true
        connectLeftFinger()
    }
    
    func stopRecordingForceData() {
        isRecording = false
    }
    
    func handleLeftFingerMessage(string: String, client: WebSocketClient) {
        if client === leftFingerSocket {
            if let data = string.data(using: .utf8) {
                if let fingerForce = try? JSONDecoder().decode(FingerFource.self, from: data) {
                    let forceData = ForceData(
                        timeStamp: "\(fingerForce.time_stamp.secs).\(fingerForce.time_stamp.nanos)",
                        forceData: fingerForce.force?.value)
//                    print("force data1: \(recordedForceData)")
                    DispatchQueue.main.async {
//                        print("force data1: \(recordedForceData)")
                        if self.isRecording {
                            self.recordedForceData.append(forceData)
                        }
                    }
                }
            }
        }
    }
}

extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            DispatchQueue.main.async {
                self.connected = true
            }
            print("WebSocket connected with headers: \(headers)")
        case .disconnected(let reason, let code):
            DispatchQueue.main.async {
                self.connected = false
            }
            print("WebSocket disconnected: \(reason) with code: \(code)")
        case .text(let string):
            if self.isRecording {
                handleLeftFingerMessage(string: string, client: client)
                print("handle finger message, is recording: \(isRecording)")
            }
//            print("Received text: \(string)")
//            DispatchQueue.main.async {
//                self.receivedMessage = string
//            }
        case .binary(let data):
            handleData(data: data, client: client)
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            DispatchQueue.main.async {
                self.connected = false
            }
            print("websocket is cancelled")
        case .peerClosed:
            break
        case .error(let error):
            DispatchQueue.main.async {
                self.connected = false
            }
            print("websocket encountered an error: \(error?.localizedDescription ?? "")")
        }
    }
    
    
    private func handleData(data: Data, client: Starscream.WebSocketClient) {
        if client === videoSocket {
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
    
    
    
    
}
