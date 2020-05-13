import Foundation
import os.log

class Files {
    let basePath: String

    init(basePath: String) {
        self.basePath = basePath
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
