//
//  RhythmicSession+CoreDataProperties.swift
//  Parkinsons
//
//  Created by SDC-USER on 10/02/26.
//
//

public import Foundation
public import CoreData


public typealias RhythmicSessionCoreDataPropertiesSet = NSSet

extension RhythmicSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RhythmicSession> {
        return NSFetchRequest<RhythmicSession>(entityName: "RhythmicSession")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var elapsedSeconds: Int32
    @NSManaged public var requestedDuration: Int32
    @NSManaged public var steps: Int32
    @NSManaged public var distanceMeters: Double
    @NSManaged public var stepLengthMeters: Double
    @NSManaged public var walkingAsymmetry: Double
    @NSManaged public var walkingSteadiness: Double

}

extension RhythmicSession : Identifiable {

}
