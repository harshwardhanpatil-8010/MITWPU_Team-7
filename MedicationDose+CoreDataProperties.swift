//
//  MedicationDose+CoreDataProperties.swift
//  Parkinsons
//
//  Created by SDC-USER on 12/02/26.
//
//

public import Foundation
public import CoreData


public typealias MedicationDoseCoreDataPropertiesSet = NSSet

extension MedicationDose {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MedicationDose> {
        return NSFetchRequest<MedicationDose>(entityName: "MedicationDose")
    }

    @NSManaged public var doseStatus: String?
    @NSManaged public var doseTime: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var logs: NSSet?
    @NSManaged public var medication: Medication?

}

// MARK: Generated accessors for logs
extension MedicationDose {

    @objc(addLogsObject:)
    @NSManaged public func addToLogs(_ value: MedicationDoseLog)

    @objc(removeLogsObject:)
    @NSManaged public func removeFromLogs(_ value: MedicationDoseLog)

    @objc(addLogs:)
    @NSManaged public func addToLogs(_ values: NSSet)

    @objc(removeLogs:)
    @NSManaged public func removeFromLogs(_ values: NSSet)

}

extension MedicationDose : Identifiable {

}
