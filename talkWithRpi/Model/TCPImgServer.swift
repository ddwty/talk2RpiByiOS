//
//  TCPImgServer.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/14/24.
//
import Foundation
import UIKit
import SwiftUI
import Network

class TCPImgServer: ObservableObject {
    @Published var receivedImages: [UIImage] = []
    @Published var isListening = false
    @Published var isLoading = false
    @Published var clientAddresses: [String] = [] // 新增：用于存储客户端地址

    private var listener: NWListener?
    private var connections: [NWConnection] = []

    func startListening(port: UInt16) {
        do {
            listener = try NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port)!)
            listener?.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    print("Listening on port \(port)")
                    self.isListening = true
                case .failed(let error):
                    print("Listener failed with error: \(error)")
                    self.listener?.cancel()
                    self.isListening = false
                default:
                    break
                }
            }
            listener?.newConnectionHandler = { newConnection in
                self.handleNewConnection(newConnection)
            }
            listener?.start(queue: .main)
        } catch {
            print("Failed to start listener: \(error)")
        }
    }

    func stopListening() {
        listener?.cancel()
        listener = nil
        isListening = false
        connections.forEach { $0.cancel() }
        connections.removeAll()
    }

    private func handleNewConnection(_ connection: NWConnection) {
      
        switch connection.endpoint {
        case .hostPort(let host, let port):
            let clientInfo = "Connected to client: \(host) at port \(port)"
            print(clientInfo)
            DispatchQueue.main.async {
                self.clientAddresses.append(clientInfo)
            }
        default:
            let clientInfo = "Connected to unknown client endpoint: \(connection.endpoint)"
            print(clientInfo)
            DispatchQueue.main.async {
                self.clientAddresses.append(clientInfo)
            }
        }

        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Client connected")
                self.connections.append(connection)
                self.receiveData(on: connection)
            case .failed(let error):
                print("Client connection failed: \(error)")
                connection.cancel()
                self.connections.removeAll { $0 === connection }
            case .cancelled:
                print("Client connection cancelled")
                self.connections.removeAll { $0 === connection }
            default:
                break
            }
        }
        connection.start(queue: .main)
    }

    private func receiveData(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                connection.cancel()
                self.connections.removeAll { $0 === connection }
                return
            }
            if let data = data {
                let length = Int(data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                if length > 0 {
                    self.receiveImage(length: length, on: connection)
                } else {
                    self.isLoading = false
                    // 不要取消连接
                    self.receiveData(on: connection)
                }
            }
        }
    }

    private func receiveImage(length: Int, on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: length, maximumLength: length) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                connection.cancel()
                self.connections.removeAll { $0 === connection }
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.receivedImages.append(image)
                }
                // 不要取消连接，继续监听
                self.receiveData(on: connection)
            }
        }
    }

    func sendCommand(command: String) {
        connections.forEach { connection in
            let dataToSend = command.data(using: .utf8)
            connection.send(content: dataToSend, completion: .contentProcessed({ error in
                if let error = error {
                    print("Send error: \(error)")
                } else {
                    print("Data sent")
                }
            }))
        }
    }
}
