//
//  PureUsbView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/13/24.
// 这是不需要任何网络的实现方式,  TEXT

import SwiftUI
import Network

struct PureUsbView: View {
    @StateObject private var tcpServer = TCPServer()
    @State private var port: String = "2345"
    @State private var messageToSend: String = ""
    
    var body: some View {
        VStack {
            Text("Server")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            connectionForm
            
            if tcpServer.isConnected {
                sendMessageForm
                ScrollView {
                    ForEach(Array(tcpServer.receivedMessages.enumerated()), id: \.offset) { index, message in
                        Text(message)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                Spacer()
//                controlButtons
            }

            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
    
    var connectionForm: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Port:")
                    .bold()
                TextField("Port", text: $port)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }

            Button(action: {
                self.startListening()
            }) {
                Text(tcpServer.isConnected ? "Restart" : "Start Listening")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    var sendMessageForm: some View {
        HStack {
            TextField("Enter message", text: $messageToSend)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            Button(action: {
                self.sendMessage()
                hideKeyboard()
            }) {
                Text("Send")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    var controlButtons: some View {
        HStack {
            Button(action: {
                self.stopSending()
            }) {
                Text("Stop Sending")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }

    func startListening() {
        guard let port = NWEndpoint.Port(port) else {
            print("Invalid port number")
            return
        }
        tcpServer.cleanupListener()  // 清理之前的监听器
        tcpServer.startListening(port: port)
    }
    
    func sendMessage() {
        tcpServer.sendMessage(messageToSend)
        messageToSend = ""
    }
    
    func stopSending() {
        tcpServer.cleanupListener()
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PureUsbView()
    }
}
