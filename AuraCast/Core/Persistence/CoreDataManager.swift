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

    func saveLocation(name: String, lat: Double, lon: Double, temperature: Int, high: Int, low: Int, weatherCondition: String) {
        let idString = "\(lat)_\(lon)"
        let request = SavedLocationEntity.fetchRequest()
        request.predicate = NSPredicate(format: "lat == %f AND lon == %f", lat, lon)
        
        let entity: SavedLocationEntity
        if let existing = (try? context.fetch(request))?.first {
            entity = existing
        } else {
            entity = SavedLocationEntity(context: context)
            entity.dateAdded = Date()
        }
        
        entity.name = name
        entity.lat = lat
        entity.lon = lon
        entity.temperature = Int16(temperature)
        entity.high = Int16(high)
        entity.low = Int16(low)
        entity.weatherCondition = weatherCondition
        
        try? context.save()
    }

    func deleteLocation(matching lat: Double, _ lon: Double) {
        let request = SavedLocationEntity.fetchRequest()
        
        if let allEntities = try? context.fetch(request) {
            let matches = allEntities.filter { $0.lat == lat && $0.lon == lon }
            matches.forEach { context.delete($0) }
            
            do {
                try context.save()
                print("Successfully deleted and saved to Core Data.")
            } catch {
                print("Failed to save context after delete: \(error)")
            }
        }
    }

    func isFavorite(lat: Double, lon: Double) -> Bool {
        let request = SavedLocationEntity.fetchRequest()
        if let allEntities = try? context.fetch(request) {
            return allEntities.contains(where: { $0.lat == lat && $0.lon == lon })
        }
        return false
    }
}
