import Foundation

extension Array {
    func filter(using predicate: NSPredicate) -> [Element] {
        (self as NSArray).filtered(using: predicate) as! [Element]
    }
}
