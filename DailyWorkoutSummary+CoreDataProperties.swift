//
//  DailyWorkoutSummary+CoreDataProperties.swift
//  Parkinsons
//
//  Created by SDC-USER on 03/02/26.
//
//

public import Foundation
public import CoreData


public typealias DailyWorkoutSummaryCoreDataPropertiesSet = NSSet

extension DailyWorkoutSummary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyWorkoutSummary> {
        return NSFetchRequest<DailyWorkoutSummary>(entityName: "DailyWorkoutSummary")
    }

    @NSManaged public var completedCount: Int16
    @NSManaged public var date: Date?
    @NSManaged public var skippedCount: Int16

}

extension DailyWorkoutSummary : Identifiable {

}
