////
////  ViaEthernetView.swift
////  talkWithRpi
////
////  Created by Tianyu on 7/16/24.
////
//
//import SwiftUI
//
//struct ViaEthernetView: View {
//    @State private var messageToSend: String = ""
//    @State private var receivedMessage: String = ""
//    private var webSocketTask: URLSessionWebSocketTask?
//
//    var body: some View {
//        VStack {
//            TextField("输入消息", text: $messageToSend)
//                .padding()
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            
//            Button(action: {
//                sendMessage(message: messageToSend)
//            }) {
//                Text("发送")
//            }
//            .padding()
//            
//            Text("收到的消息: \(receivedMessage)")
//                .padding()
//            
//            Spacer()
//        }
//        .onAppear {
//            connectWebSocket()
//        }
//        .onDisappear {
//            disconnectWebSocket()
//        }
//    }
//
//    private func connectWebSocket() {
//        let url = URL(string: "ws://169.254.248.202:8765")! // 替换为树莓派的IP地址
//        let session = URLSession(configuration: .default)
//        webSocketTask = session.webSocketTask(with: url)
//        webSocketTask?.resume()
//        
//        receiveMessage()
//    }
//
//    private func disconnectWebSocket() {
//        webSocketTask?.cancel(with: .goingAway, reason: nil)
//    }
//
//    private func sendMessage(message: String) {
//        let message = URLSessionWebSocketTask.Message.string(message)
//        webSocketTask?.send(message) { error in
//            if let error = error {
//                print("发送消息出错: \(error)")
//            }
//        }
//    }
//
//    private func receiveMessage() {
//        webSocketTask?.receive { result in
//            switch result {
//            case .failure(let error):
//                print("接收消息出错: \(error)")
//            case .success(let message):
//                switch message {
//                case .string(let text):
//                    DispatchQueue.main.async {
//                        self.receivedMessage = text
//                    }
//                case .data(let data):
//                    print("Received binary data: \(data)")
//                @unknown default:
//                    fatalError()
//                }
//                
//                // 继续接收消息
//                self.receiveMessage()
//            }
//        }
//    }
//}
//
//
//
//#Preview {
//    ViaEthernetView()
//}
