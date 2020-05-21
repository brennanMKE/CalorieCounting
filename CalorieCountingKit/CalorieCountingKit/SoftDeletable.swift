import Foundation

public protocol SoftDeletable {
    var isDeleted: Bool { get }
}

public extension Array where Element: SoftDeletable {
    var visibleItems: [Element] {
        let result = filter { !$0.isDeleted }
        return result
    }
}
