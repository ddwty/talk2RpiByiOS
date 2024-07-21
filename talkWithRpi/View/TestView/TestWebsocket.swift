//
//  testWebsocket.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/16/24.
//

import SwiftUI
import Starscream

class WebSocketManager2: ObservableObject, WebSocketDelegate {
    
    var socket: WebSocket!
    @Published var receivedMessage: String = ""
    
    init() {
        var request = URLRequest(url: URL(string: "ws://192.168.5.11:1234")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func connect() {
        socket.connect()
    }
    
    func send(message: String) {
        socket.write(string: message)
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received text: \(string)")
            DispatchQueue.main.async {
                self.receivedMessage = string
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("websocket is cancelled")
        case .error(let error):
            print("websocket encountered an error: \(error?.localizedDescription ?? "")")
        case .peerClosed:
            break
        }
    }
}

struct  TestWebsocket: View {
    @StateObject private var webSocketManager = WebSocketManager2()
    @State private var message: String = ""
    
    var body: some View {
        VStack {
            Button(action: {
                webSocketManager.connect()
            }) {
                Text("Connect to Raspberry Pi")
            }
            .padding()
            
            HStack {
                TextField("Enter message", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    webSocketManager.send(message: message)
                }) {
                    Text("Send")
                }
                .padding()
            }
            
            Text("Received message: \(webSocketManager.receivedMessage)")
                .padding()
        }
        .padding()
    }
}




#Preview {
    TestWebsocket()
}
