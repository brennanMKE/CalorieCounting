import Foundation

protocol SoftDeletable {
    var isDeleted: Bool { get }
}

extension Array where Element: SoftDeletable {
    var visibleItems: [SoftDeletable] {
        let result = filter { $0.isDeleted }
        return result
    }
}
