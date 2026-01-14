class UnitAndTypeStore {
    static let shared = UnitAndTypeStore()
    private init() {}

    var savedUnit: String?     
    var savedType: String?
    
    func reset() {
            savedUnit = nil
            savedType = nil
        }

}

