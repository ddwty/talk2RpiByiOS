//
//  PureUsbImgVieww.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/14/24.
//

import SwiftUI
import Network

struct PureUsbImgView: View {
    @StateObject private var tcpImgServer = TCPImgServer()
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
                        self.startListening()
                    }) {
                        Text("Start Listening")
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

    func startListening() {
        guard let port = UInt16(port) else {
            print("Invalid port number")
            return
        }
        tcpImgServer.startListening(port: port)
    }

    func stopListening() {
        tcpImgServer.stopListening()
    }

    func sendCommand(command: String) {
        tcpImgServer.sendCommand(command: command)
    }
}






#Preview {
    PureUsbImgView()
}
