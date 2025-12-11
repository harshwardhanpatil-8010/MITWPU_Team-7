import Foundation

class UnitAndTypeStore {
    static let shared = UnitAndTypeStore()

    private init() {}

    var savedUnit: String = ""
    var savedType: String = ""
}

