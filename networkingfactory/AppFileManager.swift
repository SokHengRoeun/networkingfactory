//
//  AppFileManager.swift
//  networkingfactory
//
//  Created by SokHeng on 14/12/22.
//

// swiftlint:disable all

import Foundation
import UIKit

class AppFileManager {
    static let shared = AppFileManager()
    private let fManager = FileManager.default
    let fileDirectoryURL = try! FileManager.default.url(for: .documentDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true)
    func storeFile(fileName: String, fileData: Data) -> String {
        var tempMessage = "fail"
        if hasFile(fileName: fileName) {
            tempMessage = "fail"
        } else {
            fManager.createFile(atPath: fileDirectoryURL.appending(path: "download/\(fileName)").path(),
                                           contents: fileData)
            tempMessage = "success"
        }
        return tempMessage
    }
    func hasFile(fileName: String) -> Bool {
        var tempMessage = false
        if fManager.fileExists(atPath: fileDirectoryURL.appending(path: "download/\(fileName)").path()) {
            tempMessage = true
        } else {
            tempMessage = false
        }
        return tempMessage
    }
    func deleteFile(fileName: String) {
        do {
            try fManager.removeItem(atPath: fileDirectoryURL.appending(path: "download/\(fileName)").path())
        } catch {
            print(">> Can't delete \(fileName) since it no longer exist.")
        }
    }
    func openFile(fileName: String) -> Data {
        var tempData = Data()
        if hasFile(fileName: fileName) {
            tempData = try! Data(contentsOf: fileDirectoryURL.appending(path: "download/\(fileName)"))
        } else {
            tempData = "Hmmm Strange!".data(using: .utf8)!
        }
        return tempData
    }
    func initOnStart() {
        // Create Download folder if it doesn't exist
        do {
            let tempPath = fileDirectoryURL.appending(path: "download").path()
            try fManager.createDirectory(atPath: tempPath,
                                         withIntermediateDirectories: true)
        } catch {
            print(">> Try to create Download Folder but it already exist.")
        }
    }
    // save download files
    func saveDownloadFile (fileData: Data, fileName: String, viewCont: UIViewController,
                           tableCell: UITableViewCell) {
        let fileListVC = viewCont as! FileListViewController
        let cell = tableCell as! MainTableViewCell
        let saveFile = AppFileManager.shared.storeFile(fileName: fileName, fileData: fileData)
        if saveFile == "success" {
            print("Downloaded file saved")
        } else {
            fileListVC.showAlertBox(title: "Download fail",
                                    message: "This file already exist in your directory",
                                    buttonAction: nil, buttonText: "Okay", buttonStyle: .default)
        }
        cell.sizeNameLabel.text = "file downloaded"
        cell.downIconImage.image = UIImage(systemName: "checkmark.seal.fill")
        cell.loadingProgressBar.isHidden = true
        cell.downIconImage.isHidden = false
        cell.spinIndicator.isHidden = true
        cell.sizeNameLabel.isHidden = false
    }
    func getAllFilesDownload(viewCont: UIViewController) -> [String] {
        let fileListVC = viewCont as! FileListViewController
        let localPath = AppFileManager.shared.fileDirectoryURL.appending(path: "download").path()
        var downloadedFiles = [String]()
        do {
            downloadedFiles = try FileManager.default.contentsOfDirectory(atPath: localPath)
            downloadedFiles = downloadedFiles.filter { $0.contains(".") }
            for item in downloadedFiles {
                print("Found \(item)")
            }
        } catch {
            print("\n>> failed to read directory – bad permissions, perhaps?\n")
        }
        if downloadedFiles.count == 0 {
            fileListVC.emptyIconImage.isHidden = false
        } else {
            fileListVC.emptyIconImage.isHidden = true
        }
        return downloadedFiles
    }
    func saveFileForUpload(fileUrl: URL) -> URL {
        let fileName = fileUrl.lastPathComponent.replacingOccurrences(of: " ", with: "_")
        deleteFile(fileName: fileName)
        do {
            try FileManager.default.createFile(atPath: fileDirectoryURL.appending(path: "download/\(fileName)").path(),
                                               contents: Data(contentsOf: fileUrl))
        } catch {
            print(">> can't create \(fileUrl) since it already existed")
        }
        return fileDirectoryURL.appending(path: "download/\(fileName)")
    }
}
