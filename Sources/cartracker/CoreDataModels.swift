import Foundation
import CoreData

// MARK: - Core Data Stack

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CarTracker")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

// MARK: - Vehicle Reading Model

@objc(VehicleReading)
public class VehicleReading: NSManagedObject {

    // MARK: - Properties

    @NSManaged public var timestamp: Date
    @NSManaged public var rpm: Int16
    @NSManaged public var speed: Int16
    @NSManaged public var engineTemp: Int16
    @NSManaged public var fuelLevel: Double
    @NSManaged public var throttlePosition: Double
    @NSManaged public var engineLoad: Double
    @NSManaged public var maf: Double
    @NSManaged public var isConnected: Bool
    @NSManaged public var trip: Trip?

    // MARK: - Computed Properties

    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }

    var rpmString: String {
        return "\(rpm) RPM"
    }

    var speedString: String {
        return "\(speed) km/h"
    }

    var tempString: String {
        return "\(engineTemp)°C"
    }

    var fuelString: String {
        return String(format: "%.1f%%", fuelLevel)
    }
}

// MARK: - Core Data Methods

extension VehicleReading {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VehicleReading> {
        return NSFetchRequest<VehicleReading>(entityName: "VehicleReading")
    }

    @nonobjc public class func deleteRequest() -> NSBatchDeleteRequest {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "VehicleReading")
        return NSBatchDeleteRequest(fetchRequest: fetchRequest)
    }

    // MARK: - Convenience Initializer

    convenience init(context: NSManagedObjectContext,
                    timestamp: Date = Date(),
                    rpm: Int,
                    speed: Int,
                    engineTemp: Int,
                    fuelLevel: Double,
                    throttlePosition: Double,
                    engineLoad: Double,
                    maf: Double,
                    isConnected: Bool = true) {

        self.init(context: context)
        self.timestamp = timestamp
        self.rpm = Int16(rpm)
        self.speed = Int16(speed)
        self.engineTemp = Int16(engineTemp)
        self.fuelLevel = fuelLevel
        self.throttlePosition = throttlePosition
        self.engineLoad = engineLoad
        self.maf = maf
        self.isConnected = isConnected
    }

    // MARK: - Class Methods

    class func create(from vehicleData: VehicleData, in context: NSManagedObjectContext) -> VehicleReading {
        return VehicleReading(
            context: context,
            timestamp: vehicleData.lastUpdate,
            rpm: vehicleData.rpm,
            speed: vehicleData.speed,
            engineTemp: vehicleData.engineTemp,
            fuelLevel: vehicleData.fuelLevel,
            throttlePosition: vehicleData.throttlePosition,
            engineLoad: vehicleData.engineLoad,
            maf: vehicleData.maf,
            isConnected: vehicleData.isConnected
        )
    }
}

// MARK: - Trip Model

@objc(Trip)
public class Trip: NSManagedObject {

    @NSManaged public var id: UUID
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date?
    @NSManaged public var distance: Double  // km
    @NSManaged public var averageSpeed: Double  // km/h
    @NSManaged public var fuelConsumption: Double  // L/100km
    @NSManaged public var maxRPM: Int16
    @NSManaged public var maxSpeed: Int16
    @NSManaged public var readings: NSSet?

    var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }

    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60

        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %ds", minutes, seconds)
        }
    }

    var formattedDistance: String {
        return String(format: "%.1f km", distance)
    }

    var formattedAverageSpeed: String {
        return String(format: "%.1f km/h", averageSpeed)
    }

    var formattedFuelConsumption: String {
        return String(format: "%.1f L/100km", fuelConsumption)
    }
}

// MARK: - Trip Core Data Methods

extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    convenience init(context: NSManagedObjectContext,
                    startTime: Date = Date(),
                    distance: Double = 0,
                    averageSpeed: Double = 0,
                    fuelConsumption: Double = 0,
                    maxRPM: Int = 0,
                    maxSpeed: Int = 0) {

        self.init(context: context)
        self.id = UUID()
        self.startTime = startTime
        self.distance = distance
        self.averageSpeed = averageSpeed
        self.fuelConsumption = fuelConsumption
        self.maxRPM = Int16(maxRPM)
        self.maxSpeed = Int16(maxSpeed)
    }

    // MARK: - Accessors for readings

    @objc(addReadingsObject:)
    @NSManaged public func addToReadings(_ value: VehicleReading)

    @objc(removeReadingsObject:)
    @NSManaged public func removeFromReadings(_ value: VehicleReading)

    @objc(addReadings:)
    @NSManaged public func addToReadings(_ values: NSSet)

    @objc(removeReadings:)
    @NSManaged public func removeFromReadings(_ values: NSSet)
}

// MARK: - Generated accessors for VehicleReading

extension VehicleReading {

    @objc(addTripObject:)
    @NSManaged public func addToTrip(_ value: Trip)

    @objc(removeTripObject:)
    @NSManaged public func removeFromTrip(_ value: Trip)

    @objc(addTrip:)
    @NSManaged public func addToTrip(_ values: NSSet)

    @objc(removeTrip:)
    @NSManaged public func removeFromTrip(_ values: NSSet)
}