//
//  SeverView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/13/24.
//

import SwiftUI
import Network

struct SeverView: View {
    @State private var listener: NWListener?
    @State private var receivedImages: [UIImage] = []
    @State private var isListening = false
    @State private var isLoading = false

    var body: some View {
        VStack {
            Text("TCP Server")
                .font(.largeTitle)
                .padding()

            if isListening {
                if isLoading {
                    ProgressView("Loading images...")
                        .padding()
                } else {
                    ScrollView {
                        ForEach(receivedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .padding()
                        }
                    }
                }

                Button(action: {
                    self.stopListening()
                }) {
                    Text("Stop Listening")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Button(action: {
                    self.startListening()
                }) {
                    Text("Start Listening")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }

    func startListening() {
        do {
            listener = try NWListener(using: .tcp, on: 8909)  // 替换为你想要监听的端口
            listener?.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    print("Listening on port 1234")
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
    }

    func handleNewConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Client connected")
                self.receiveData(on: connection)
            case .failed(let error):
                print("Client connection failed: \(error)")
            case .cancelled:
                print("Client connection cancelled")
            default:
                break
            }
        }
        connection.start(queue: .main)
    }

    func receiveData(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                connection.cancel()
                return
            }
            if let data = data {
                let length = Int(data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                if length > 0 {
                    self.receiveImage(length: length, on: connection)
                } else {
                    self.isLoading = false
                    connection.cancel()
                }
            }
        }
    }

    func receiveImage(length: Int, on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: length, maximumLength: length) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                connection.cancel()
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.receivedImages.append(image)
                }
                self.receiveData(on: connection)  // Continue receiving next image
            }
        }
    }
}



#Preview {
    SeverView()
}
