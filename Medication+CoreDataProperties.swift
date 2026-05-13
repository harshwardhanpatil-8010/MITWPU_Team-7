//
//  Medication+CoreDataProperties.swift
//  Parkinsons
//
//  Created by SDC-USER on 12/02/26.
//
//

public import Foundation
public import CoreData


public typealias MedicationCoreDataPropertiesSet = NSSet

extension Medication {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medication> {
        return NSFetchRequest<Medication>(entityName: "Medication")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var medicationForm: String?
    @NSManaged public var medicationIconName: String?
    @NSManaged public var medicationName: String?
    @NSManaged public var medicationScheduleDays: NSObject?
    @NSManaged public var medicationScheduleType: String?
    @NSManaged public var medicationStrength: Int16
    @NSManaged public var medicationUnit: String?
    @NSManaged public var doses: NSSet?
    @NSManaged public var logs: NSSet?

}

extension Medication {

    @objc(addDosesObject:)
    @NSManaged public func addToDoses(_ value: MedicationDose)

    @objc(removeDosesObject:)
    @NSManaged public func removeFromDoses(_ value: MedicationDose)

    @objc(addDoses:)
    @NSManaged public func addToDoses(_ values: NSSet)

    @objc(removeDoses:)
    @NSManaged public func removeFromDoses(_ values: NSSet)

}

extension Medication {

    @objc(addLogsObject:)
    @NSManaged public func addToLogs(_ value: MedicationDoseLog)

    @objc(removeLogsObject:)
    @NSManaged public func removeFromLogs(_ value: MedicationDoseLog)

    @objc(addLogs:)
    @NSManaged public func addToLogs(_ values: NSSet)

    @objc(removeLogs:)
    @NSManaged public func removeFromLogs(_ values: NSSet)

}

extension Medication : Identifiable {

}
