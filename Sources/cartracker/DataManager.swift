import Foundation
import CoreData

// MARK: - Data Manager

class DataManager {
    static let shared = DataManager()

    private let persistenceController = PersistenceController.shared
    private var currentTrip: Trip?

    private init() {
        // Crear las entidades si no existen
        createEntitiesIfNeeded()
    }

    // MARK: - Public Methods

    /// Guarda una nueva lectura del vehículo
    func saveReading(from vehicleData: VehicleData) {
        let context = persistenceController.container.viewContext

        context.perform { [weak self] in
            guard let self = self else { return }

            // Crear la lectura
            let reading = VehicleReading.create(from: vehicleData, in: context)

            // Asociar con el viaje actual
            if let currentTrip = self.currentTrip {
                reading.trip = currentTrip
                self.updateTripStatistics(with: reading, in: context)
            }

            // Guardar
            do {
                try context.save()
                print("✅ Lectura guardada: \(reading.formattedTimestamp)")
            } catch {
                print("❌ Error guardando lectura: \(error.localizedDescription)")
            }
        }
    }

    /// Obtiene todas las lecturas ordenadas por timestamp (más recientes primero)
    func fetchReadings(limit: Int = 1000) -> [VehicleReading] {
        let context = persistenceController.container.viewContext
        let request = VehicleReading.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = limit

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error obteniendo lecturas: \(error.localizedDescription)")
            return []
        }
    }

    /// Obtiene lecturas en un rango de fechas
    func fetchReadings(from startDate: Date, to endDate: Date) -> [VehicleReading] {
        let context = persistenceController.container.viewContext
        let request = VehicleReading.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error obteniendo lecturas por fecha: \(error.localizedDescription)")
            return []
        }
    }

    /// Obtiene lecturas de un viaje específico
    func fetchReadings(for trip: Trip) -> [VehicleReading] {
        let context = persistenceController.container.viewContext
        let request = VehicleReading.fetchRequest()
        request.predicate = NSPredicate(format: "trip == %@", trip)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error obteniendo lecturas del viaje: \(error.localizedDescription)")
            return []
        }
    }

    /// Obtiene todos los viajes ordenados por fecha de inicio
    func fetchTrips() -> [Trip] {
        let context = persistenceController.container.viewContext
        let request = Trip.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error obteniendo viajes: \(error.localizedDescription)")
            return []
        }
    }

    /// Inicia un nuevo viaje
    func startNewTrip() {
        let context = persistenceController.container.viewContext

        // Finalizar viaje anterior si existe
        if let currentTrip = currentTrip {
            endCurrentTrip()
        }

        // Crear nuevo viaje
        currentTrip = Trip(context: context)

        do {
            try context.save()
            print("✅ Nuevo viaje iniciado: \(currentTrip?.id.uuidString ?? "unknown")")
        } catch {
            print("❌ Error iniciando viaje: \(error.localizedDescription)")
        }
    }

    /// Finaliza el viaje actual
    func endCurrentTrip() {
        guard let trip = currentTrip else { return }

        let context = persistenceController.container.viewContext
        trip.endTime = Date()

        // Calcular estadísticas finales
        let readings = fetchReadings(for: trip)
        if !readings.isEmpty {
            updateTripStatisticsFinal(trip, with: readings, in: context)
        }

        do {
            try context.save()
            print("✅ Viaje finalizado: \(trip.formattedDuration)")
            currentTrip = nil
        } catch {
            print("❌ Error finalizando viaje: \(error.localizedDescription)")
        }
    }

    /// Elimina lecturas antiguas (más de 30 días)
    func deleteOldReadings(olderThan days: Int = 30) {
        let context = persistenceController.container.viewContext
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()

        let request = VehicleReading.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp < %@", cutoffDate as NSDate)

        do {
            let oldReadings = try context.fetch(request)
            for reading in oldReadings {
                context.delete(reading)
            }
            try context.save()
            print("🗑️ Eliminadas \(oldReadings.count) lecturas antiguas")
        } catch {
            print("❌ Error eliminando lecturas antiguas: \(error.localizedDescription)")
        }
    }

    /// Exporta todas las lecturas a CSV
    func exportToCSV() -> String? {
        let readings = fetchReadings(limit: 10000) // Máximo 10k lecturas

        if readings.isEmpty {
            return nil
        }

        var csv = "Timestamp,RPM,Speed (km/h),Engine Temp (°C),Fuel Level (%),Throttle Position (%),Engine Load (%),MAF (g/s),Connected\n"

        for reading in readings.reversed() { // Más antiguos primero
            let row = [
                reading.timestamp.ISO8601Format(),
                "\(reading.rpm)",
                "\(reading.speed)",
                "\(reading.engineTemp)",
                String(format: "%.2f", reading.fuelLevel),
                String(format: "%.2f", reading.throttlePosition),
                String(format: "%.2f", reading.engineLoad),
                String(format: "%.2f", reading.maf),
                reading.isConnected ? "Yes" : "No"
            ].joined(separator: ",")
            csv += row + "\n"
        }

        return csv
    }

    /// Obtiene estadísticas generales
    func getStatistics() -> VehicleStatistics {
        let readings = fetchReadings(limit: 10000)

        guard !readings.isEmpty else {
            return VehicleStatistics.empty
        }

        let rpmValues = readings.map { Int($0.rpm) }
        let speedValues = readings.map { Int($0.speed) }
        let tempValues = readings.map { Int($0.engineTemp) }
        let fuelValues = readings.map { $0.fuelLevel }

        return VehicleStatistics(
            totalReadings: readings.count,
            averageRPM: Double(rpmValues.reduce(0, +)) / Double(rpmValues.count),
            maxRPM: rpmValues.max() ?? 0,
            averageSpeed: Double(speedValues.reduce(0, +)) / Double(speedValues.count),
            maxSpeed: speedValues.max() ?? 0,
            averageTemp: Double(tempValues.reduce(0, +)) / Double(tempValues.count),
            maxTemp: tempValues.max() ?? 0,
            averageFuelLevel: fuelValues.reduce(0, +) / Double(fuelValues.count),
            totalTrips: fetchTrips().count,
            oldestReading: readings.map { $0.timestamp }.min(),
            newestReading: readings.map { $0.timestamp }.max()
        )
    }

    // MARK: - Private Methods

    private func createEntitiesIfNeeded() {
        let context = persistenceController.container.viewContext

        // Verificar si las entidades ya existen
        let vehicleRequest = VehicleReading.fetchRequest()
        vehicleRequest.fetchLimit = 1

        let tripRequest = Trip.fetchRequest()
        tripRequest.fetchLimit = 1

        do {
            let vehicleCount = try context.count(for: vehicleRequest)
            let tripCount = try context.count(for: tripRequest)

            if vehicleCount == 0 && tripCount == 0 {
                print("📊 Inicializando base de datos CarTracker...")
                try context.save()
            }
        } catch {
            print("⚠️ Error verificando entidades: \(error.localizedDescription)")
        }
    }

    private func updateTripStatistics(with reading: VehicleReading, in context: NSManagedObjectContext) {
        guard let trip = currentTrip else { return }

        // Actualizar estadísticas del viaje
        trip.maxRPM = max(trip.maxRPM, reading.rpm)
        trip.maxSpeed = max(trip.maxSpeed, reading.speed)

        // Calcular distancia aproximada (basado en velocidad y tiempo)
        // Esto es una aproximación simple - en producción usar GPS
        let readings = fetchReadings(for: trip)
        if readings.count > 1 {
            let sortedReadings = readings.sorted { $0.timestamp < $1.timestamp }
            var totalDistance = 0.0
            var totalSpeed = 0.0

            for i in 1..<sortedReadings.count {
                let prevReading = sortedReadings[i-1]
                let currentReading = sortedReadings[i]
                let timeDiff = currentReading.timestamp.timeIntervalSince(prevReading.timestamp)
                let avgSpeed = Double(prevReading.speed + currentReading.speed) / 2.0 / 3600.0 // km/h a km/s
                totalDistance += avgSpeed * timeDiff
                totalSpeed += Double(currentReading.speed)
            }

            trip.distance = totalDistance
            trip.averageSpeed = totalSpeed / Double(readings.count)
        }
    }

    private func updateTripStatisticsFinal(_ trip: Trip, with readings: [VehicleReading], in context: NSManagedObjectContext) {
        guard !readings.isEmpty else { return }

        let speeds = readings.map { Double($0.speed) }
        let fuelLevels = readings.map { $0.fuelLevel }

        // Calcular consumo de combustible aproximado
        if fuelLevels.count > 1 {
            let initialFuel = fuelLevels.first ?? 0
            let finalFuel = fuelLevels.last ?? 0
            let fuelUsed = max(0, initialFuel - finalFuel)

            // Estimación simple: asumir tanque de 50L
            if fuelUsed > 0 {
                trip.fuelConsumption = (fuelUsed / 100.0) * 50.0 / (trip.distance / 100.0)
            }
        }
    }
}

// MARK: - Vehicle Statistics

struct VehicleStatistics {
    let totalReadings: Int
    let averageRPM: Double
    let maxRPM: Int
    let averageSpeed: Double
    let maxSpeed: Int
    let averageTemp: Double
    let maxTemp: Int
    let averageFuelLevel: Double
    let totalTrips: Int
    let oldestReading: Date?
    let newestReading: Date?

    static let empty = VehicleStatistics(
        totalReadings: 0,
        averageRPM: 0,
        maxRPM: 0,
        averageSpeed: 0,
        maxSpeed: 0,
        averageTemp: 0,
        maxTemp: 0,
        averageFuelLevel: 0,
        totalTrips: 0,
        oldestReading: nil,
        newestReading: nil
    )

    var formattedTotalReadings: String {
        return "\(totalReadings) lecturas"
    }

    var formattedAverageRPM: String {
        return String(format: "%.0f RPM", averageRPM)
    }

    var formattedMaxRPM: String {
        return "\(maxRPM) RPM"
    }

    var formattedAverageSpeed: String {
        return String(format: "%.1f km/h", averageSpeed)
    }

    var formattedMaxSpeed: String {
        return "\(maxSpeed) km/h"
    }

    var formattedAverageTemp: String {
        return String(format: "%.1f°C", averageTemp)
    }

    var formattedMaxTemp: String {
        return "\(maxTemp)°C"
    }

    var formattedAverageFuelLevel: String {
        return String(format: "%.1f%%", averageFuelLevel)
    }

    var formattedTotalTrips: String {
        return "\(totalTrips) viajes"
    }

    var formattedDateRange: String {
        guard let oldest = oldestReading, let newest = newestReading else {
            return "Sin datos"
        }

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none

        return "\(formatter.string(from: oldest)) - \(formatter.string(from: newest))"
    }
}