import Foundation
import os.log

class FileStore {
    enum Failure: Error {
        case fileExistsAtDirectoryPath
        case failedToCreateDirectory(Error)
    }

    let baseURL: URL

    static var `default` : FileStore = {
        return FileStore()
    }()

    init(baseURL: URL = FileStore.baseDocumentURL) {
        self.baseURL = baseURL
    }

    static var baseDocumentURL: URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url
    }

    func createDirectoryIfNotExists(_ directoryURL: URL) throws {
        var isDir : ObjCBool = false

        let exists = FileManager.default.fileExists(atPath: directoryURL.path, isDirectory:&isDir)
        if !exists {
            do {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                os_log(.error, log: Logger.dataStore, "Failed to create directory")
                throw Failure.failedToCreateDirectory(error)
            }
        } else if exists && !isDir.boolValue {
            os_log(.error, log: Logger.dataStore, "File does not exist")
            throw Failure.fileExistsAtDirectoryPath
        }
    }

    func isDirectory(url: URL) -> Bool {
        var isDir : ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory:&isDir)
        let result = isDir.boolValue && exists
        return result
    }

    func childURLs(url: URL) throws -> [URL] {
        let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        return result
    }

    func collectFiles(url: URL, filter: @escaping (String) -> Bool) -> [URL] {
        var fileURLs: [URL] = []
        if !isDirectory(url: url) {
            if filter(url.path) {
                fileURLs.append(url)
            }
        }
        if let childURLs = try? childURLs(url: url) {
            childURLs.forEach {
                fileURLs.append(contentsOf: collectFiles(url: $0, filter: filter))
            }
        } else {
            os_log(.error, log: Logger.dataStore, "Failed to to get child URLs")
        }

        return fileURLs
    }

}
