//
//  TCPServer.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/13/24.
//

import Foundation
import Network

class TCPServer: ObservableObject {
    private var listener: NWListener?
    @Published var isConnected = false
    @Published var receivedMessages: [String] = []
    private var connection: NWConnection?
    
    func startListening(port: NWEndpoint.Port) {
        do {
            listener = try NWListener(using: .tcp, on: port)
        } catch {
            print("Failed to create listener: \(error)")
            return
        }
        
        listener?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Server ready and listening on port \(port)")
                DispatchQueue.main.async {
                    self.isConnected = true
                }
            case .failed(let error):
                print("Server failed: \(error)")
                self.cleanupListener()
            default:
                break
            }
        }
        
        listener?.newConnectionHandler = { newConnection in
            self.handleNewConnection(newConnection)
        }
        
        listener?.start(queue: .main)
    }
    
    private func handleNewConnection(_ connection: NWConnection) {
        self.connection = connection
        connection.start(queue: .main)
        receive(on: connection)
    }
    
    private func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                return
            }
            if let data = data, let message = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.receivedMessages.append(message)
                }
                self.receive(on: connection)  // Continue receiving next message
            }
        }
    }
    
    func sendMessage(_ message: String) {
        guard let connection = connection else { return }
        connection.send(content: message.data(using: .utf8), completion: .contentProcessed({ error in
            if let error = error {
                print("Send error: \(error)")
            } else {
                print("Sent: \(message)")
            }
        }))
    }
    
    func cleanupListener() {
        listener?.cancel()
        listener = nil
        connection?.cancel()
        connection = nil
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
}
