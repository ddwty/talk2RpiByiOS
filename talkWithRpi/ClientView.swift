import SwiftUI
import Network

struct ClientView: View {
    @State private var connection: NWConnection?
    @State private var receivedImages: [UIImage] = []
    @State private var isConnected = false
    @State private var isLoading = false
    @State private var port: String = "1234"

    var body: some View {
        VStack {
            Text("TCP Client")
                .font(.largeTitle)
                .padding()
            

            if isConnected {
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
                    self.reloadImages()
                }) {
                    Text("Reload Images")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    self.disconnect()
                }) {
                    Text("Disconnect")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                Button(action: {
                    self.startConnection()
                }) {
                    Text("Connect")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }

    func startConnection() {
        let host = NWEndpoint.Host("172.20.10.2") // 树莓派的实际 IP 地址
        let port = NWEndpoint.Port("12233")!

        connection = NWConnection(host: host, port: port, using: .tcp)
        connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Connected to server")
                self.isConnected = true
                self.reloadImages()
            case .failed(let error):
                print("Connection failed: \(error)")
                self.cleanupConnection()
            default:
                break
            }
        }
        connection?.start(queue: .main)
    }

    func reloadImages() {
        guard let connection = connection else { return }
        isLoading = true
        receivedImages.removeAll()  // 清空图像数组

        connection.send(content: "GET_IMAGES".data(using: .utf8), completion: .contentProcessed({ error in
            if let error = error {
                print("Send failed: \(error)")
            } else {
                print("Request sent")
                self.receive()
            }
        }))
    }

    func receive() {
        connection?.receive(minimumIncompleteLength: 4, maximumLength: 4) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                self.cleanupConnection()
                return
            }
            if let data = data {
                let length = Int(data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian })
                if length > 0 {
                    self.receiveImage(length: length)
                } else {
                    self.isLoading = false
                }
            }
        }
    }

    func receiveImage(length: Int) {
        connection?.receive(minimumIncompleteLength: length, maximumLength: length) { (data, _, _, error) in
            if let error = error {
                print("Receive error: \(error)")
                self.cleanupConnection()
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.receivedImages.append(image)
                }
                self.receive()  // Continue receiving next image
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

    func cleanupConnection() {
        connection?.cancel()
        connection = nil
        isConnected = false
        isLoading = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ClientView()
    }
}
