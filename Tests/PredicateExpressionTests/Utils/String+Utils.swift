import Foundation

extension String {
    subscript(prefix offset: Int) -> Self {
        prefix(through: index(startIndex, offsetBy: offset)).description
    }

    subscript(suffix offset: Int) -> Self {
        suffix(from: index(startIndex, offsetBy: count - offset)).description
    }

    subscript(value index: Int) -> Self {
        let val = self[prefix: index]
        return val.last?.description ?? ""
    }
}
