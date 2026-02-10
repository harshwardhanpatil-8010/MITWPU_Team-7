//
//  RhythmicSessionStore.swift
//  Parkinsons
//
//  Created by SDC-USER on 10/02/26.
//

import Foundation
import CoreData
import CoreData

final class RhythmicSessionStore {

    private let persistence = PersistenceController.shared

    func save(builder: RhythmicSessionBuilder) {

        let context = persistence.newBackgroundContext()

        context.perform {
            let session = RhythmicSession(context: context)

            session.startDate = builder.startDate
            session.endDate = builder.endDate
            session.elapsedSeconds = Int32(
                builder.endDate.timeIntervalSince(builder.startDate)
            )

            session.steps = Int32(builder.steps)
            session.distanceMeters = builder.distanceMeters
            session.stepLengthMeters = builder.stepLengthMeters
            session.walkingAsymmetry = builder.walkingAsymmetry
            session.walkingSteadiness = builder.walkingSteadiness

            self.persistence.save(context)
        }
    }
}
