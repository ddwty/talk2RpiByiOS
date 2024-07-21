//
//  ViaWifiViewModel.swift
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

struct ImuData: Codable {
    let quat: [Double]
    let time_stamp: TimeStamp
}

struct FingerForce: Codable {
    let force: [Double]?
    let time_stamp: TimeStamp
}

class WebSocketManager: ObservableObject {
    @Published var imuData: ImuData?
    @Published var fingerData: FingerForce?
    @Published var time: TimeStamp?
    @Published var connected = false
    @Published var isRecording = false
    @Published var image: UIImage?
    @Published var hostName: String = "raspberrypi.local"
    
    private var imuSocket: WebSocket?
    private var videoSocket: WebSocket?
    private var leftFingerSocket: WebSocket?
    private var socket: WebSocket?
    

    init() {
        connect()
        pingServer()
        var request = URLRequest(url: URL(string: "ws://\(hostName)")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
    }
    
    func connect() {
        socket?.connect()
       
        var request = URLRequest(url: URL(string: "ws://\(self.hostName):8080/imu")!)
        imuSocket = WebSocket(request: request)
        imuSocket?.delegate = self
        imuSocket?.connect()
        
        request = URLRequest(url: URL(string: "ws://\(self.hostName):8080/camera")!)
        videoSocket = WebSocket(request: request)
        videoSocket?.delegate = self
        videoSocket?.connect()
        
        request = URLRequest(url: URL(string: "ws://\(self.hostName):8080/left_finger/force")!)
        leftFingerSocket = WebSocket(request: request)
        leftFingerSocket?.delegate = self
        leftFingerSocket?.connect()
    }
    
    func disconnect() {
        imuSocket?.disconnect()
        videoSocket?.disconnect()
        leftFingerSocket?.disconnect()
    }
    
    func pingServer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let url = URL(string: "http://\(self.hostName):8080/ping") else { return }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    DispatchQueue.main.async {
                        self.connected = (httpResponse.statusCode == 200)
                        print("Connected")
                    }
                }
            }.resume()
        }
    }
    
    func calibrateIMU() {
        guard let url = URL(string: "http://\(self.hostName):8080/imu/calibrate") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func startRecording() {
        let recordCommand: [String: Any] = [
            "Start": [
                "imu": "./data/imu.csv",
                "env_camera": "./data/camera.mp4",
                "left_finger": "./data/leftfinger.csv",
                "right_finger": "./data/rightfinger.csv"
            ]
        ]
        guard let url = URL(string: "http://\(self.hostName):8080/recordstart") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: recordCommand)
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func endRecording() {
        guard let url = URL(string: "http://\(self.hostName):8080/recordend") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request).resume()
    }
    
    func downloadData() {
        let urls = [
            "http://\(self.hostName):8080/data/imu.csv",
            "http://\(self.hostName):8080/data/camera.mp4",
            "http://\(self.hostName):8080/data/leftfinger.csv",
            "http://\(self.hostName):8080/data/rightfinger.csv"
        ]
        
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if data != nil {
                    print("Downloaded: \(urlString)")
                    // Handle the downloaded data (e.g., save to disk)
                }
            }.resume()
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
            handleMessage(string: string, client: client)
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
        case .peerClosed:
            break
        case .error(let error):
            DispatchQueue.main.async {
                self.connected = false
            }
            print("WebSocket error: \(String(describing: error))")
        }
    }
    
    private func handleMessage(string: String, client: Starscream.WebSocketClient) {
        if client === imuSocket {
            if let data = string.data(using: .utf8) {
                let imuData = try? JSONDecoder().decode(ImuData.self, from: data)
                DispatchQueue.main.async {
                    self.imuData = imuData
                }
            }
        } else if client === videoSocket {
            if string == "blocked" {
                print("Video blocked")
            } else {
                if let data = string.data(using: .utf8) {
                    let timeStamp = try? JSONDecoder().decode(TimeStamp.self, from: data)
                    DispatchQueue.main.async {
                        self.time = timeStamp
                    }
                }
            }
        } else if client === leftFingerSocket {
            if let data = string.data(using: .utf8) {
                let fingerData = try? JSONDecoder().decode(FingerForce.self, from: data)
                DispatchQueue.main.async {
                    self.fingerData = fingerData
                }
            }
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
