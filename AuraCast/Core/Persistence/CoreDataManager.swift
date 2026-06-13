//
//  CoreDataManager.swift
//  AuraCast
//
//  Created by Ahmed El Sayyad Mohamed on 11/06/2026.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "AuraCast")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("CoreData failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var context: NSManagedObjectContext { container.viewContext }

    func fetchAllLocations() -> [SavedLocationEntity] {
        let request = SavedLocationEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func saveLocation(name: String, lat: Double, lon: Double) {
        let entity = SavedLocationEntity(context: context)
        entity.name = name
        entity.lat = lat
        entity.lon = lon
        entity.dateAdded = Date()
        try? context.save()
    }

    func deleteLocation(matching lat: Double, _ lon: Double) {
        let entities = fetchAllLocations().filter { $0.lat == lat && $0.lon == lon }
        entities.forEach { context.delete($0) }
        try? context.save()
    }

    func isFavorite(lat: Double, lon: Double) -> Bool {
        fetchAllLocations().contains { $0.lat == lat && $0.lon == lon }
    }
}
