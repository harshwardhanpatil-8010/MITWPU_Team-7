//
//  MedicationDoseLog+CoreDataProperties.swift
//  Parkinsons
//
//  Created by SDC-USER on 12/02/26.
//
//

public import Foundation
public import CoreData


public typealias MedicationDoseLogCoreDataPropertiesSet = NSSet

extension MedicationDoseLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MedicationDoseLog> {
        return NSFetchRequest<MedicationDoseLog>(entityName: "MedicationDoseLog")
    }

    @NSManaged public var doseDay: Date?
    @NSManaged public var doseLoggedAt: Date?
    @NSManaged public var doseLogStatus: String?
    @NSManaged public var doseScheduledTime: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var dose: MedicationDose?
    @NSManaged public var medication: Medication?

}

extension MedicationDoseLog : Identifiable {

}
