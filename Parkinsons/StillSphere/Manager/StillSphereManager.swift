// StillSphereManager.swift
// Parkinsons

import Foundation
import CoreData

final class StillSphereManager {
    static let shared = StillSphereManager()
    
    private let completionKey = "StillSphere_CompletedDates"
    
    private init() {}
    
    // MARK: - Daily Completion
    
    func isCompleted(date: Date) -> Bool {
        let dateString = formatDate(date)
        let completedDates = UserDefaults.standard.stringArray(forKey: completionKey) ?? []
        return completedDates.contains(dateString)
    }
    
    func markAsCompleted(date: Date) {
        let dateString = formatDate(date)
        var completedDates = UserDefaults.standard.stringArray(forKey: completionKey) ?? []
        if !completedDates.contains(dateString) {
            completedDates.append(dateString)
            UserDefaults.standard.set(completedDates, forKey: completionKey)
        }
        
        // Notify the app that a game was completed (Home Screen refresh)
        NotificationCenter.default.post(name: NSNotification.Name("didUpdateGameCompletion"), object: nil)
    }
    
    // MARK: - Persistence (Core Data)
    
    func saveSessionSummary(level: String, duration: Double, steadiness: Double, sensitivity: String, date: Date = Date()) {
        let context = PersistenceController.shared.viewContext
        let summary = StillSphereSessionSummary(context: context)
        summary.id = UUID()
        summary.date = date
        summary.levelName = level
        summary.sessionDuration = duration
        summary.steadinessScore = steadiness
        summary.sensitivityMode = sensitivity
        
        PersistenceController.shared.save(context)
        
        // Mark the specific session date as completed
        markAsCompleted(date: date)
    }
    
    // MARK: - Helpers
    
    func getSessionSummaries(from startDate: Date, to endDate: Date) -> [StillSphereSessionSummary] {
        let context = PersistenceController.shared.viewContext
        let fetchRequest: NSFetchRequest<StillSphereSessionSummary> = StillSphereSessionSummary.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching StillSphere summaries: \(error)")
            return []
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
