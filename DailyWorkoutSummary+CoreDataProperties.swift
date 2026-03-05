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

    @NSManaged public var completedExerciseIDs: NSObject?
    @NSManaged public var completedExerciseNames: NSObject?
    @NSManaged public var completedCount: Int16
    @NSManaged public var date: Date?
    @NSManaged public var skippedExerciseIDs: NSObject?
    @NSManaged public var skippedExerciseNames: NSObject?
    @NSManaged public var skippedCount: Int16
    @NSManaged public var totalExercises: Int16

}

extension DailyWorkoutSummary : Identifiable {

}
