import Foundation

@frozen
enum URLType {
    case file
    case directory
    case notExists

    init(url: URL) {
        var isDir : ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory:&isDir)

        if !exists {
            self = .notExists
        } else {
            self = isDir.boolValue ? .directory : .file
        }
    }
}

struct Node {
    let path: String
    let urlType: URLType
    let nodes: [Node]
}

extension Node: CustomStringConvertible {
    var description: String {
        let result: String
        switch urlType {
        case .file:
            result = path
        case .directory:
            let nodePaths = nodes.map { $0.path }.joined(separator: ", ")
            result = "\(path): \(nodePaths)"
        case .notExists:
            result = "Not Exists"
        }

        return result
    }
}

//

let basePath = "/var/documents/"

let dir1 = Node(path: "12", urlType: .directory, nodes: [
    Node(path: "\(basePath)/2020/5/12/file1.json", urlType: .file, nodes: []),
    Node(path: "\(basePath)/2020/5/12/file2.json", urlType: .file, nodes: []),
    Node(path: "\(basePath)/2020/5/12/file3.json", urlType: .file, nodes: [])
])
let dir2 = Node(path: "14", urlType: .directory, nodes: [
    Node(path: "\(basePath)/2020/5/14/file4.json", urlType: .file, nodes: []),
    Node(path: "\(basePath)/2020/5/14/file5.json", urlType: .file, nodes: []),
    Node(path: "\(basePath)/2020/5/14/file6.json", urlType: .file, nodes: []),
    Node(path: "\(basePath)/2020/5/14/error.log", urlType: .file, nodes: [])
])

let dir3 = Node(path: "\(basePath)/2020/5", urlType: .directory, nodes: [dir1, dir2])
let dir4 = Node(path: "\(basePath)2020", urlType: .directory, nodes: [dir3])

func print(node: Node) {
    print(node)
    node.nodes.forEach {
        print(node: $0)
    }
}

func collectFiles(node: Node, filter: @escaping (String) -> Bool) -> [Node] {
    var fileNodes: [Node] = []
    if node.urlType == .file {
        if filter(node.path) {
            fileNodes.append(node)
        }
    }
    node.nodes.forEach {
        fileNodes.append(contentsOf: collectFiles(node: $0, filter: filter))
    }

    return fileNodes
}

let pattern = #".+\d+/\d+/\d+/.+\.json$"#
print(pattern)
let regex = try! NSRegularExpression(pattern: pattern)

let regexFilter: (String) -> Bool = {
    guard $0.hasPrefix(basePath) else {
        return false
    }
    let nsrange = NSRange($0.startIndex..<$0.endIndex, in: $0)
    let result = regex.matches(in: $0, options: [], range: nsrange).count > 0
    return result
}

let suffixFilter: (String) -> Bool = {
    let result = $0.hasSuffix(".json")
    return result
}

let strings = ["\(basePath)2020/3/12/file.json", "\(basePath)2020/3/app.config", "\(basePath)2020/3/12/error.log"]

strings.forEach {
    print(regexFilter($0) ? "matched" : "no match")
}

let fileNodes = collectFiles(node: dir4, filter: regexFilter)

fileNodes.forEach {
    print($0)
}

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
        }

        return fileURLs
    }
}

