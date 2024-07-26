//
//  HistoryView.swift
//  talkWithRpi
//
//  Created by Tianyu on 7/22/24.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct HistoryView: View {
    @Query private var recordings: [ARStorgeData]
    @State private var navigationPath: [ARStorgeData] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(recordings) { recording in
                Button(action: {
                    navigationPath.append(recording)
                }) {
                    VStack(alignment: .leading) {
                        Text("Created at: \(recording.createTime, formatter: dateFormatter)")
                        Text("Duration: \(recording.timeDuration, specifier: "%.2f") seconds")
                    }
                }
            }
            .navigationTitle("History")
            .navigationDestination(for: ARStorgeData.self) { recording in
                RecordingDetailView(recording: recording)
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview(traits: .landscapeRight) {
    HistoryView()
}
//struct RecordingDetailView: View {
//    let recording: ARStorgeData
//    @State private var isFileExporterPresented = false
//    @State private var csvOutputURL: URL? = nil
//
//    var body: some View {
//        VStack {
//            Text("Duration: \(recording.timeDuration, specifier: "%.2f") seconds")
//                .padding()
//
//            Button("Export CSV File") {
//                exportFrameDataToCSV()
//                if csvOutputURL != nil {
//                    isFileExporterPresented = true
//                } else {
//                    print("Error creating CSV file.")
//                }
//            }
//            .fileExporter(
//                isPresented: $isFileExporterPresented,
//                document: CSVDocument(fileURL: csvOutputURL ?? URL(fileURLWithPath: "")),
//                contentType: .commaSeparatedText,
//                defaultFilename: "exportedData"
//            ) { result in
//                switch result {
//                case .success(let url):
//                    print("File exported to: \(url)")
//                case .failure(let error):
//                    print("Export failed: \(error.localizedDescription)")
//                }
//            }
//        }
//        .navigationTitle("Recording Details")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//
//    private func exportFrameDataToCSV() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
//        let dateString = dateFormatter.string(from: Date())
//        
//        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
//        csvOutputURL = tempDirectory.appendingPathComponent(dateString + "frameData").appendingPathExtension("csv")
//        
//        var csvText = "Timestamp,CameraTransform\n"
//        for frameData in recording.data {
//            let timestamp = frameData.timestamp
//            let transform = frameData.transform
//            let transformString = "\(transform.columns.0.x),\(transform.columns.0.y),\(transform.columns.0.z),\(transform.columns.0.w)," +
//            "\(transform.columns.1.x),\(transform.columns.1.y),\(transform.columns.1.z),\(transform.columns.1.w)," +
//            "\(transform.columns.2.x),\(transform.columns.2.y),\(transform.columns.2.z),\(transform.columns.2.w)," +
//            "\(transform.columns.3.x),\(transform.columns.3.y),\(transform.columns.3.z),\(transform.columns.3.w)"
//            csvText.append("\(timestamp),\(transformString)\n")
//        }
//        
//        do {
//            try csvText.write(to: csvOutputURL!, atomically: true, encoding: .utf8)
//            print("CSV saved to: \(csvOutputURL!.absoluteString)")
//        } catch {
//            print("Error saving CSV: \(error.localizedDescription)")
//        }
//    }
//}

struct RecordingDetailView: View {
    @Bindable var recording: ARStorgeData
    @State private var isFileExporterPresented = false
    @State private var csvOutputURL: URL? = nil

    var body: some View {
        VStack {
            Text("Duration: \(recording.timeDuration, specifier: "%.2f") seconds")
                .padding()

//            Button("Export CSV File") {
//                exportFrameDataToCSV()
//                if csvOutputURL != nil {
//                    isFileExporterPresented = true
//                } else {
//                    print("Error creating CSV file.")
//                }
//            }
//            .fileExporter(
//                isPresented: $isFileExporterPresented,
//                document: CSVDocument(fileURL: csvOutputURL ?? URL(fileURLWithPath: "")),
//                contentType: .commaSeparatedText,
//                defaultFilename: "exportedData"
//            ) { result in
//                switch result {
//                case .success(let url):
//                    print("File exported to: \(url)")
//                case .failure(let error):
//                    print("Export failed: \(error.localizedDescription)")
//                }
//            }
        }
        .navigationTitle("Recording Details")
        .navigationBarTitleDisplayMode(.inline)
    }

//    private func exportFrameDataToCSV() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
//        let dateString = dateFormatter.string(from: Date())
//        
//        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
//        csvOutputURL = tempDirectory.appendingPathComponent(dateString + "frameData").appendingPathExtension("csv")
//        
//        var csvText = "Timestamp,CameraTransform\n"
//        for frameData in recording.data {
//            let timestamp = frameData.timestamp
//            let transform = frameData.transform
//            let transformString = "\(transform.columns.0.x),\(transform.columns.0.y),\(transform.columns.0.z),\(transform.columns.0.w)," +
//            "\(transform.columns.1.x),\(transform.columns.1.y),\(transform.columns.1.z),\(transform.columns.1.w)," +
//            "\(transform.columns.2.x),\(transform.columns.2.y),\(transform.columns.2.z),\(transform.columns.2.w)," +
//            "\(transform.columns.3.x),\(transform.columns.3.y),\(transform.columns.3.z),\(transform.columns.3.w)"
//            csvText.append("\(timestamp),\(transformString)\n")
//        }
//        
//        do {
//            try csvText.write(to: csvOutputURL!, atomically: true, encoding: .utf8)
//            print("CSV saved to: \(csvOutputURL!.absoluteString)")
//        } catch {
//            print("Error saving CSV: \(error.localizedDescription)")
//        }
//    }
}


struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    init(configuration: ReadConfiguration) throws {
        self.fileURL = URL(fileURLWithPath: "")
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: fileURL)
    }
}

