//
//  CDSymptomLog+CoreDataProperties.swift
//  Parkinsons
//
//  Created by SDC-USER on 09/02/26.
//
//

public import Foundation
public import CoreData


public typealias CDSymptomLogCoreDataPropertiesSet = NSSet

extension CDSymptomLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDSymptomLog> {
        return NSFetchRequest<CDSymptomLog>(entityName: "CDSymptomLog")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var notes: NSObject?
    @NSManaged public var severity: Int16
    @NSManaged public var symptom: Int16

}

extension CDSymptomLog : Identifiable {

}
