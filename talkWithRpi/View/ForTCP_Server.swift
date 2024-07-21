//
//  ForTCP_Server.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/15/24.
//

import SwiftUI
import Network

struct ForTCP_Server: View {
    @StateObject private var tcpImgClient = TCPImgClient3()
        @State private var port: String = "2345" // 这里仍然是iPhone上的端口

        var body: some View {
            NavigationView {
                VStack {
                    Text("TCP Image Client")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 40)

                    connectionForm

                    if tcpImgClient.isConnected {
                        if tcpImgClient.isLoading {
                            ProgressView("Loading images...")
                                .padding()
                        } else {
                            ScrollView {
                                ForEach(tcpImgClient.receivedImages, id: \.self) { image in
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
                            Text("Connect to Server")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    Spacer()
                }
                .padding()
                .navigationTitle("Client Control")
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
            guard let port = UInt16(port) else {
                print("Invalid port number")
                return
            }
            tcpImgClient.connectToServer(port: port)
        }

        func sendCommand(command: String) {
            tcpImgClient.sendCommand(command: command)
        }
}

#Preview {
    ForTCP_Server()
}
class TCPImgClient3: ObservableObject {
    @Published var receivedImages: [UIImage] = []
        @Published var isConnected = false
        @Published var isLoading = false

        private var connection: NWConnection?

        func connectToServer(port: UInt16) {
            let host = NWEndpoint.Host("127.0.0.1")
            let nwPort = NWEndpoint.Port(rawValue: port)!

            connection = NWConnection(host: host, port: nwPort, using: .tcp)
            connection?.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    print("Connected to server")
                    self.isConnected = true
                    self.receiveData()
                case .failed(let error):
                    print("Connection failed: \(error)")
                    self.isConnected = false
                case .cancelled:
                    print("Connection cancelled")
                    self.isConnected = false
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
                    self.isConnected = false
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
                    self.isConnected = false
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
            guard let connection = connection else {
                return
            }
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
