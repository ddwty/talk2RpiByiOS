//
//  ClientView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/13/24.
// 这是树莓派作为服务器，iPhone作为客户端的实现方式


//import SwiftUI
//import Network
//
//struct ClientView: View {
//    @StateObject private var tcpClient = TCPClient()
//    @State private var ipAddress: String = "127.0.0.1"
//    @State private var port: String = "1234"
//
//    var body: some View {
//        VStack {
//            Text("TCP Client")
//                .font(.largeTitle)
//                .bold()
//                .padding(.top, 40)
//
//            VStack(spacing: 20) {
//                HStack {
//                    Text("IP Address:")
//                        .bold()
//                    TextField("IP Address", text: $ipAddress)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .keyboardType(.numbersAndPunctuation)
//                }
//
//                HStack {
//                    Text("Port:")
//                        .bold()
//                    TextField("Port", text: $port)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                        .keyboardType(.numberPad)
//                }
//
//                Button(action: {
//                    self.startConnection()
//                }) {
//                    Text(tcpClient.isConnected ? "Reconnect" : "Connect")
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.green)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//
//            if tcpClient.isConnected {
//                if tcpClient.isLoading {
//                    ProgressView("Loading images...")
//                        .padding()
//                } else {
//                    ScrollView {
//                        ForEach(tcpClient.receivedImages, id: \.self) { image in
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 200)
//                                .padding(.horizontal, 20)
//                                .padding(.vertical, 10)
//                        }
//                    }
//                }
//
//                HStack {
//                    Button(action: {
//                        self.reloadImages()
//                    }) {
//                        Text("Reload Images")
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//
//                    Button(action: {
//                        self.disconnect()
//                    }) {
//                        Text("Disconnect")
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.red)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 20)
//            }
//
//            Spacer()
//        }
//        .padding()
//        .background(Color(UIColor.systemGroupedBackground))
//        .edgesIgnoringSafeArea(.all)
//    }
//
//    func startConnection() {
//        guard let port = NWEndpoint.Port(port) else {
//            print("Invalid port number")
//            return
//        }
//        let host = NWEndpoint.Host(ipAddress)
//        tcpClient.startConnection(host: host, port: port) {
//            // Connection ready
//            tcpClient.reloadImages(onReceive: {})
//        } onFail: { error in
//            // Connection failed
//        }
//    }
//
//    func reloadImages() {
//        tcpClient.reloadImages {
//            // Images reloaded
//        }
//    }
//
//    func disconnect() {
//        tcpClient.disconnect()
//    }
//}


import Foundation
import UIKit
import SwiftUI
import Network

class TCPImgServer2: ObservableObject {
    @Published var receivedImages: [UIImage] = []
    @Published var isListening = false
    @Published var isLoading = false

    private var connection: NWConnection?
    
    func startConnection(host: NWEndpoint.Host, port: NWEndpoint.Port) {
        connection = NWConnection(host: host, port: port, using: .tcp)
        connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Connected to \(host) on port \(port)")
                self.isListening = true
                self.receiveData()
            case .failed(let error):
                print("Connection failed with error: \(error)")
                self.isListening = false
                self.connection?.cancel()
            case .cancelled:
                print("Connection cancelled")
                self.isListening = false
            default:
                break
            }
        }
        connection?.start(queue: .main)
    }

    private func receiveData() {
        connection?.receive(minimumIncompleteLength: 4, maximumLength: 4) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                self.connection?.cancel()
                return
            }
            if let data = data {
                let length = Int(data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                if length > 0 {
                    self.receiveImage(length: length)
                } else {
                    self.isLoading = false
                    self.receiveData()
                }
            }
        }
    }

    private func receiveImage(length: Int) {
        connection?.receive(minimumIncompleteLength: length, maximumLength: length) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                self.connection?.cancel()
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.receivedImages.append(image)
                }
                self.receiveData()
            }
        }
    }

    func sendCommand(command: String) {
        let dataToSend = command.data(using: .utf8)
        connection?.send(content: dataToSend, completion: .contentProcessed({ error in
            if let error = error {
                print("Send error: \(error)")
            } else {
                print("Data sent")
            }
        }))
    }
}


struct ClientView: View {
    @StateObject private var tcpImgServer = TCPImgServer2()
    @State private var port: String = "2345"

    var body: some View {
        NavigationView {
            VStack {
                Text("TCP Image Server")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)

                connectionForm

                if tcpImgServer.isListening {
                    if tcpImgServer.isLoading {
                        ProgressView("Loading images...")
                            .padding()
                    } else {
                        ScrollView {
                            ForEach(tcpImgServer.receivedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .padding()
                            }
                        }
                    }

                    HStack {
                        Button(action: {
                            self.sendCommand(command: "GET_IMAGES")
                        }) {
                            Text("Receive Images")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top, 20)
                } else {
                    Button(action: {
                        self.startConnection()
                    }) {
                        Text("Start Connection")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Server Control")
            .navigationBarTitleDisplayMode(.inline)
        }
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
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    func startConnection() {
        guard let port = NWEndpoint.Port(port) else {
            print("Invalid port number")
            return
        }
        tcpImgServer.startConnection(host: "127.0.0.1", port: port)
    }

    func sendCommand(command: String) {
        tcpImgServer.sendCommand(command: command)
    }
}



struct ClientView_Previews: PreviewProvider {
    static var previews: some View {
        ClientView()
    }
}
