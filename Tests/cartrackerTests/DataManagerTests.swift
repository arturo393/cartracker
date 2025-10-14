import XCTest
@testable import cartracker

final class DataManagerTests: XCTestCase {

    var dataManager: DataManager!
    var testVehicleData: VehicleData!

    override func setUp() {
        super.setUp()

        // Usar base de datos en memoria para tests
        dataManager = DataManager()

        // Crear datos de prueba
        testVehicleData = VehicleData()
        testVehicleData.rpm = 2500
        testVehicleData.speed = 80
        testVehicleData.engineTemp = 90
        testVehicleData.fuelLevel = 75.0
        testVehicleData.throttlePosition = 25.0
        testVehicleData.engineLoad = 45.0
        testVehicleData.maf = 12.5
        testVehicleData.isConnected = true
        testVehicleData.lastUpdate = Date()
    }

    override func tearDown() {
        // Limpiar datos después de cada test
        dataManager = nil
        testVehicleData = nil
        super.tearDown()
    }

    func testSaveReading() {
        // Given
        let initialCount = dataManager.fetchReadings().count

        // When
        dataManager.saveReading(from: testVehicleData)

        // Then
        let readings = dataManager.fetchReadings()
        XCTAssertEqual(readings.count, initialCount + 1)

        let savedReading = readings.first!
        XCTAssertEqual(savedReading.rpm, Int16(testVehicleData.rpm))
        XCTAssertEqual(savedReading.speed, Int16(testVehicleData.speed))
        XCTAssertEqual(savedReading.engineTemp, Int16(testVehicleData.engineTemp))
        XCTAssertEqual(savedReading.fuelLevel, testVehicleData.fuelLevel)
        XCTAssertEqual(savedReading.throttlePosition, testVehicleData.throttlePosition)
        XCTAssertEqual(savedReading.engineLoad, testVehicleData.engineLoad)
        XCTAssertEqual(savedReading.maf, testVehicleData.maf)
        XCTAssertEqual(savedReading.isConnected, testVehicleData.isConnected)
    }

    func testFetchReadingsLimit() {
        // Given - Crear múltiples lecturas
        for i in 0..<5 {
            var data = VehicleData()
            data.rpm = 1000 + i * 500
            data.lastUpdate = Date().addingTimeInterval(Double(i) * 60) // Cada minuto
            dataManager.saveReading(from: data)
        }

        // When
        let limitedReadings = dataManager.fetchReadings(limit: 3)

        // Then
        XCTAssertEqual(limitedReadings.count, 3)
        // Deberían estar ordenadas por timestamp descendente (más recientes primero)
        XCTAssertGreaterThanOrEqual(limitedReadings[0].timestamp, limitedReadings[1].timestamp)
    }

    func testFetchReadingsByDateRange() {
        // Given
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!

        // Crear lecturas con diferentes timestamps
        var oldData = VehicleData()
        oldData.rpm = 1500
        oldData.lastUpdate = yesterday

        var newData = VehicleData()
        newData.rpm = 3000
        newData.lastUpdate = now

        dataManager.saveReading(from: oldData)
        dataManager.saveReading(from: newData)

        // When
        let recentReadings = dataManager.fetchReadings(from: yesterday, to: tomorrow)

        // Then
        XCTAssertEqual(recentReadings.count, 2)
    }

    func testStartNewTrip() {
        // Given
        let initialTripCount = dataManager.fetchTrips().count

        // When
        dataManager.startNewTrip()

        // Then
        let trips = dataManager.fetchTrips()
        XCTAssertEqual(trips.count, initialTripCount + 1)

        let newTrip = trips.first!
        XCTAssertNotNil(newTrip.id)
        XCTAssertNil(newTrip.endTime)
        XCTAssertEqual(newTrip.distance, 0)
    }

    func testEndCurrentTrip() {
        // Given
        dataManager.startNewTrip()
        let tripBeforeEnd = dataManager.fetchTrips().first!

        // When
        dataManager.endCurrentTrip()

        // Then
        let trips = dataManager.fetchTrips()
        let endedTrip = trips.first!
        XCTAssertNotNil(endedTrip.endTime)
        XCTAssertGreaterThan(endedTrip.endTime!, endedTrip.startTime)
    }

    func testExportToCSV() {
        // Given
        dataManager.saveReading(from: testVehicleData)

        // When
        let csv = dataManager.exportToCSV()

        // Then
        XCTAssertNotNil(csv)
        XCTAssertTrue(csv!.contains("Timestamp,RPM,Speed"))
        XCTAssertTrue(csv!.contains("2500")) // RPM
        XCTAssertTrue(csv!.contains("80"))   // Speed
        XCTAssertTrue(csv!.contains("90"))   // Temp
        XCTAssertTrue(csv!.contains("75.0")) // Fuel
    }

    func testGetStatistics() {
        // Given - Crear varias lecturas
        for i in 0..<3 {
            var data = VehicleData()
            data.rpm = 2000 + i * 500
            data.speed = 60 + i * 20
            data.engineTemp = 85 + i * 5
            data.fuelLevel = 80.0 - Double(i) * 10.0
            dataManager.saveReading(from: data)
        }

        // When
        let stats = dataManager.getStatistics()

        // Then
        XCTAssertEqual(stats.totalReadings, 3)
        XCTAssertEqual(stats.averageRPM, 2500.0) // (2000 + 2500 + 3000) / 3
        XCTAssertEqual(stats.maxRPM, 3000)
        XCTAssertEqual(stats.averageSpeed, 80.0)  // (60 + 80 + 100) / 3
        XCTAssertEqual(stats.maxSpeed, 100)
        XCTAssertEqual(stats.averageTemp, 90.0)   // (85 + 90 + 95) / 3
        XCTAssertEqual(stats.maxTemp, 95)
        XCTAssertEqual(stats.averageFuelLevel, 70.0) // (80 + 70 + 60) / 3
    }

    func testDeleteOldReadings() {
        // Given - Crear lecturas con diferentes fechas
        let oldDate = Calendar.current.date(byAdding: .day, value: -40, to: Date())!
        let recentDate = Date()

        var oldData = VehicleData()
        oldData.rpm = 1500
        oldData.lastUpdate = oldDate

        var recentData = VehicleData()
        recentData.rpm = 2500
        recentData.lastUpdate = recentDate

        dataManager.saveReading(from: oldData)
        dataManager.saveReading(from: recentData)

        let readingsBeforeDelete = dataManager.fetchReadings()
        XCTAssertEqual(readingsBeforeDelete.count, 2)

        // When
        dataManager.deleteOldReadings(olderThan: 30)

        // Then
        let readingsAfterDelete = dataManager.fetchReadings()
        XCTAssertEqual(readingsAfterDelete.count, 1)
        XCTAssertEqual(readingsAfterDelete.first!.rpm, Int16(2500))
    }

    func testVehicleReadingFormattedProperties() {
        // Given
        let reading = dataManager.fetchReadings().first ?? {
            dataManager.saveReading(from: testVehicleData)
            return dataManager.fetchReadings().first!
        }()

        // Then
        XCTAssertEqual(reading.rpmString, "2500 RPM")
        XCTAssertEqual(reading.speedString, "80 km/h")
        XCTAssertEqual(reading.tempString, "90°C")
        XCTAssertEqual(reading.fuelString, "75.0%")
        XCTAssertFalse(reading.formattedTimestamp.isEmpty)
    }

    func testEmptyStatistics() {
        // Given - Sin datos
        // (Limpiar cualquier dato existente)

        // When
        let stats = dataManager.getStatistics()

        // Then
        XCTAssertEqual(stats.totalReadings, 0)
        XCTAssertEqual(stats.averageRPM, 0)
        XCTAssertEqual(stats.maxRPM, 0)
        XCTAssertEqual(stats.averageSpeed, 0)
        XCTAssertEqual(stats.maxSpeed, 0)
        XCTAssertEqual(stats.averageTemp, 0)
        XCTAssertEqual(stats.maxTemp, 0)
        XCTAssertEqual(stats.averageFuelLevel, 0)
        XCTAssertEqual(stats.totalTrips, 0)
        XCTAssertNil(stats.oldestReading)
        XCTAssertNil(stats.newestReading)
    }
}