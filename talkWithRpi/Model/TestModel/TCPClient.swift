////
////  TCPClient.swift
////  talkWithRpi
////
////  Created by Tianyu on 7/13/24.
////
//
import Network
import UIKit
import Combine

class TCPClient: ObservableObject {
    private var connection: NWConnection?
    @Published var isConnected = false
    @Published var isLoading = false
    @Published var receivedImages: [UIImage] = []
    
    func startConnection(host: NWEndpoint.Host, port: NWEndpoint.Port, onReady: @escaping () -> Void, onFail: @escaping (Error) -> Void) {
        connection = NWConnection(host: host, port: port, using: .tcp)
        connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Connected to server")
                DispatchQueue.main.async {
                    self.isConnected = true
                }
                onReady()
            case .failed(let error):
                print("Connection failed: \(error)")
                self.cleanupConnection()
                onFail(error)
            default:
                break
            }
        }
        connection?.start(queue: .main)
    }
    
    func reloadImages(onReceive: @escaping () -> Void) {
        guard let connection = connection else { return }
        DispatchQueue.main.async {
            self.isLoading = true
            self.receivedImages.removeAll()  // 清空图像数组
        }

        connection.send(content: "GET_IMAGES".data(using: .utf8), completion: .contentProcessed({ error in
            if let error = error {
                print("Send failed: \(error)")
            } else {
                print("Request sent")
                self.receive(onReceive: onReceive)
            }
        }))
    }

    private func receive(onReceive: @escaping () -> Void) {
        connection?.receive(minimumIncompleteLength: 4, maximumLength: 4) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                self.cleanupConnection()
                return
            }
            if let data = data {
                let length = Int(data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                if length > 0 {
                   self.receiveImage(length: length, onReceive: onReceive)
               } else {
                   DispatchQueue.main.async {
                       self.isLoading = false
                   }
               }
           }
       }
   }

   private func receiveImage(length: Int, onReceive: @escaping () -> Void) {
       connection?.receive(minimumIncompleteLength: length, maximumLength: length) { (data, _, _, error) in
           if let error = error {
               print("Receive error: \(error)")
               self.cleanupConnection()
               return
           }
           if let data = data, let image = UIImage(data: data) {
               DispatchQueue.main.async {
                   self.receivedImages.append(image)
                   onReceive()
               }
               self.receive(onReceive: onReceive)  // Continue receiving next image
           }
       }
   }

   func disconnect() {
        guard let connection = connection else { return }
        connection.send(content: "CLOSE".data(using: .utf8), completion: .contentProcessed({ error in
            if let error = error {
                print("Send failed: \(error)")
            } else {
                print("Disconnect request sent")
                self.cleanupConnection()
            }
        }))
    }

    private func cleanupConnection() {
        connection?.cancel()
        connection = nil
        DispatchQueue.main.async {
            self.isConnected = false
            self.isLoading = false
        }
    }
}

import Network
import Combine

class TCPClient2: ObservableObject {
    private var connection: NWConnection?
    @Published var isConnected = false
    @Published var messages: [String] = []
    
    func startConnection(host: NWEndpoint.Host, port: NWEndpoint.Port, onReady: @escaping () -> Void, onFail: @escaping (Error) -> Void) {
        connection = NWConnection(host: host, port: port, using: .tcp)
        connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Connected to server")
                DispatchQueue.main.async {
                    self.isConnected = true
                }
                onReady()
                self.receiveMessages()
            case .failed(let error):
                print("Connection failed: \(error)")
                self.cleanupConnection()
                onFail(error)
            default:
                break
            }
        }
        connection?.start(queue: .main)
    }
    
    func sendMessage(_ message: String) {
        guard let connection = connection else { return }
        
        connection.send(content: message.data(using: .utf8), completion: .contentProcessed({ error in
            if let error = error {
                print("Send failed: \(error)")
            } else {
                print("Message sent")
                DispatchQueue.main.async {
                    self.messages.append("Sent: \(message)")
                }
            }
        }))
    }
    
    private func receiveMessages() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                self.cleanupConnection()
                return
            }
            if let data = data, let message = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.messages.append("Received: \(message)")
                }
                self.receiveMessages()  // 继续接收消息
            }
        }
    }

    func disconnect() {
        guard let connection = connection else { return }
        connection.cancel()
        cleanupConnection()
    }
    
    private func cleanupConnection() {
        connection?.cancel()
        connection = nil
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
}
