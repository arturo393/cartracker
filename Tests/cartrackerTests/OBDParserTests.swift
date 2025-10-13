import XCTest
@testable import cartracker

final class OBDResponseParserTests: XCTestCase {
    
    // MARK: - RPM Tests
    
    func testParseRPM_ValidResponse() {
        // RPM de 2000 = (0x1F * 256 + 0x40) / 4 = 2000
        let response = "41 0C 1F 40"
        let result = OBDResponseParser.parseRPM(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 2000)
    }
    
    func testParseRPM_IdleSpeed() {
        // RPM de 800 = (0x0C * 256 + 0x80) / 4 = 800
        let response = "41 0C 0C 80"
        let result = OBDResponseParser.parseRPM(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 800)
    }
    
    func testParseRPM_HighRPM() {
        // RPM de 6000 = (0x5D * 256 + 0xC0) / 4 = 6000
        let response = "41 0C 5D C0"
        let result = OBDResponseParser.parseRPM(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 6000)
    }
    
    func testParseRPM_InvalidResponse() {
        let response = "41 0C"
        let result = OBDResponseParser.parseRPM(response)
        
        XCTAssertNil(result)
    }
    
    // MARK: - Speed Tests
    
    func testParseSpeed_ValidResponse() {
        // Velocidad de 100 km/h
        let response = "41 0D 64"
        let result = OBDResponseParser.parseSpeed(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 100)
    }
    
    func testParseSpeed_Zero() {
        let response = "41 0D 00"
        let result = OBDResponseParser.parseSpeed(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0)
    }
    
    func testParseSpeed_MaxSpeed() {
        // Velocidad de 255 km/h
        let response = "41 0D FF"
        let result = OBDResponseParser.parseSpeed(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 255)
    }
    
    // MARK: - Temperature Tests
    
    func testParseTemperature_NormalOperating() {
        // 90°C = 130 - 40
        let response = "41 05 82"
        let result = OBDResponseParser.parseTemperature(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 90)
    }
    
    func testParseTemperature_Cold() {
        // 0°C = 40 - 40
        let response = "41 05 28"
        let result = OBDResponseParser.parseTemperature(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0)
    }
    
    func testParseTemperature_Hot() {
        // 110°C = 150 - 40
        let response = "41 05 96"
        let result = OBDResponseParser.parseTemperature(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 110)
    }
    
    func testParseTemperature_BelowZero() {
        // -20°C = 20 - 40
        let response = "41 05 14"
        let result = OBDResponseParser.parseTemperature(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, -20)
    }
    
    // MARK: - Fuel Level Tests
    
    func testParseFuelLevel_Full() {
        // 100% = (255 * 100) / 255
        let response = "41 2F FF"
        let result = OBDResponseParser.parseFuelLevel(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 100.0, accuracy: 0.1)
    }
    
    func testParseFuelLevel_Half() {
        // 50% = (127 * 100) / 255
        let response = "41 2F 7F"
        let result = OBDResponseParser.parseFuelLevel(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 49.8, accuracy: 0.5)
    }
    
    func testParseFuelLevel_Empty() {
        // 0%
        let response = "41 2F 00"
        let result = OBDResponseParser.parseFuelLevel(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0.0, accuracy: 0.1)
    }
    
    // MARK: - Throttle Position Tests
    
    func testParseThrottlePosition_Idle() {
        // 0% = (0 * 100) / 255
        let response = "41 11 00"
        let result = OBDResponseParser.parseThrottlePosition(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0.0, accuracy: 0.1)
    }
    
    func testParseThrottlePosition_HalfThrottle() {
        // 50% = (127 * 100) / 255
        let response = "41 11 7F"
        let result = OBDResponseParser.parseThrottlePosition(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 49.8, accuracy: 0.5)
    }
    
    func testParseThrottlePosition_WideOpen() {
        // 100% = (255 * 100) / 255
        let response = "41 11 FF"
        let result = OBDResponseParser.parseThrottlePosition(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 100.0, accuracy: 0.1)
    }
    
    // MARK: - Engine Load Tests
    
    func testParseEngineLoad_Low() {
        // 25% = (63 * 100) / 255
        let response = "41 04 3F"
        let result = OBDResponseParser.parseEngineLoad(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 24.7, accuracy: 0.5)
    }
    
    func testParseEngineLoad_High() {
        // 80% = (204 * 100) / 255
        let response = "41 04 CC"
        let result = OBDResponseParser.parseEngineLoad(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 80.0, accuracy: 0.5)
    }
    
    // MARK: - MAF Tests
    
    func testParseMAF_IdleFlow() {
        // 5.0 g/s = (0x01 * 256 + 0xF4) / 100 = 5.0
        let response = "41 10 01 F4"
        let result = OBDResponseParser.parseMAF(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 5.0, accuracy: 0.1)
    }
    
    func testParseMAF_HighFlow() {
        // 150.0 g/s = (0x3A * 256 + 0x98) / 100 = 150.0
        let response = "41 10 3A 98"
        let result = OBDResponseParser.parseMAF(response)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 150.0, accuracy: 0.1)
    }
    
    func testParseMAF_InvalidResponse() {
        let response = "41 10 00"
        let result = OBDResponseParser.parseMAF(response)
        
        XCTAssertNil(result)
    }
    
    // MARK: - DTC Tests
    
    func testParseDTCs_SingleCode() {
        // P0300 = 0x0300
        let response = "43 01 03 00"
        let result = OBDResponseParser.parseDTCs(response)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.code, "P0300")
    }
    
    func testParseDTCs_MultipleCodes() {
        // P0300 y P0420
        let response = "43 02 03 00 04 20"
        let result = OBDResponseParser.parseDTCs(response)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains(where: { $0.code == "P0300" }))
        XCTAssertTrue(result.contains(where: { $0.code == "P0420" }))
    }
    
    func testParseDTCs_NoCodes() {
        let response = "43 00"
        let result = OBDResponseParser.parseDTCs(response)
        
        XCTAssertEqual(result.count, 0)
    }
}

// MARK: - OBD Command Tests

final class OBDCommandTests: XCTestCase {
    
    func testInitCommands_ContainsReset() {
        XCTAssertTrue(OBDCommand.initCommands.contains("ATZ"))
    }
    
    func testInitCommands_ContainsEchoOff() {
        XCTAssertTrue(OBDCommand.initCommands.contains("ATE0"))
    }
    
    func testPIDCommand_RPM() {
        let command = OBDPIDMode01.engineRPM.command
        XCTAssertEqual(command, "010C")
    }
    
    func testPIDCommand_Speed() {
        let command = OBDPIDMode01.vehicleSpeed.command
        XCTAssertEqual(command, "010D")
    }
    
    func testPIDCommand_Temperature() {
        let command = OBDPIDMode01.engineCoolantTemp.command
        XCTAssertEqual(command, "0105")
    }
}

// MARK: - DTC Code Tests

final class DTCCodeTests: XCTestCase {
    
    func testDTCCode_KnownCode() {
        let dtc = DTCCode(code: "P0300")
        
        XCTAssertEqual(dtc.code, "P0300")
        XCTAssertEqual(dtc.description, "Fallos de encendido aleatorios detectados")
        XCTAssertEqual(dtc.severity, .major)
    }
    
    func testDTCCode_UnknownCode() {
        let dtc = DTCCode(code: "P9999")
        
        XCTAssertEqual(dtc.code, "P9999")
        XCTAssertEqual(dtc.description, "Código de error desconocido")
        XCTAssertEqual(dtc.severity, .minor)
    }
    
    func testDTCCode_CriticalCode() {
        // Buscar si hay algún código crítico en la lista
        let criticalCodes = DTCCode.knownCodes.filter { $0.value.severity == .critical }
        XCTAssertFalse(criticalCodes.isEmpty, "Deberían existir códigos críticos")
    }
}

// MARK: - Vehicle Data Tests

final class VehicleDataTests: XCTestCase {
    
    func testVehicleData_InitialState() {
        let data = VehicleData()
        
        XCTAssertEqual(data.rpm, 0)
        XCTAssertEqual(data.speed, 0)
        XCTAssertEqual(data.engineTemp, 0)
        XCTAssertEqual(data.fuelLevel, 0.0)
        XCTAssertEqual(data.throttlePosition, 0.0)
        XCTAssertEqual(data.engineLoad, 0.0)
        XCTAssertEqual(data.maf, 0.0)
        XCTAssertFalse(data.isConnected)
        XCTAssertEqual(data.errorCodes.count, 0)
    }
    
    func testVehicleData_UpdateValues() {
        let data = VehicleData()
        
        data.rpm = 2000
        data.speed = 80
        data.engineTemp = 90
        data.isConnected = true
        
        XCTAssertEqual(data.rpm, 2000)
        XCTAssertEqual(data.speed, 80)
        XCTAssertEqual(data.engineTemp, 90)
        XCTAssertTrue(data.isConnected)
    }
}
