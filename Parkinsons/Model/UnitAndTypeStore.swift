class UnitAndTypeStore {
    static let shared = UnitAndTypeStore()
    private init() {}

    var savedUnit: String?      // optional
    var savedType: String?      // optional
}

