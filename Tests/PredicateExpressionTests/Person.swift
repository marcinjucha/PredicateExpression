import Foundation
import XCTest

@objcMembers
class Person: NSObject {
    let name: String
    let age: Int
    var parents: [Person] = []
    var partner: Person!
    var children: [Person] = []

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

struct PersonTestData {

    var maleNames = ["Maxwell", "Conner", "Farhan", "Alan", "Harley", "Erik", "Jeremiah", "Charles", "Robbie", "Omar", "Oliver", "Julia", "Jimmy", "Yasin", "Ellis", "Kieron", "Anas", "Hamish", "Leonard", "Roman"]
    var femaleNames = ["Thea", "Gabrielle", "Charlie", "Aimee", "Jacqueline", "Adele", "Marie", "Amirah", "Amie", "Beth", "Tiana", "Orla", "Harris", "Jessie", "Hollie", "Rachel", "Faith", "Rose", "Mary", "Linda"]

    var test: [Person] {
        (1 ... 100).map { _ in
            let partner = partnerTest
            let children = childrenTest
            let person = Person(name: Bool.random() ? maleNames.randomElement()! : femaleNames.randomElement()!,
                                age: Int.random(in: 20 ... 100))
            person.partner = partner
            partner.partner = person
            person.children = children
            partner.children = children
            children.forEach { $0.parents = [person, partner] }

            return person
        }
    }

    var partnerTest: Person {
        Person(name: Bool.random() ? maleNames.randomElement()! : femaleNames.randomElement()!,
               age: Int.random(in: 20 ... 100))
    }

    var childrenTest: [Person] {
        (1 ... Int.random(in: 1 ... 20)).map { _ in
            Person(name: Bool.random() ? maleNames.randomElement()! : femaleNames.randomElement()!,
                   age: Int.random(in: 5 ... 15))
        }
    }
}
