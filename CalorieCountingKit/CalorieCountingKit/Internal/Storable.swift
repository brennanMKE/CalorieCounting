import Foundation

protocol Storable {
    var data: Data? { get }
    func getData() throws -> Data
}
