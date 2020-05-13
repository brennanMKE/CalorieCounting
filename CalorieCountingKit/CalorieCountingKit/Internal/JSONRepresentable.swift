import Foundation

protocol JSONRepresentable: Codable, Storable {
    init(data: Data) throws
    init(fileURL: URL) throws
    func writeJSON(fileURL: URL) throws
    var jsonData: Data { get }
}

extension JSONRepresentable {
    var jsonData: Data {
        let data = (try? JSON.encoder.encode(self)) ?? Data()
        return data
    }

    var jsonString: String {
        let string = String(data: jsonData, encoding: .utf8) ?? ""
        return string
    }

    init(data: Data) throws {
        self = try JSON.decoder.decode(Self.self, from: data)
    }

    init(fileURL: URL) throws {
        let data = try Data(contentsOf: fileURL)
        try self.init(data: data)
    }

    func writeJSON(fileURL: URL) throws {
        try jsonData.write(to: fileURL)
    }

    // MARK: - Storable -

    var data: Data? {
        let data = try? getData()
        return data
    }

    func getData() throws -> Data {
        let data = try JSON.encoder.encode(self)
        return data
    }
}

extension Array where Element: JSONRepresentable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSON.decoder
        let result = try decoder.decode(Self.self, from: data)
        return result
    }
}
