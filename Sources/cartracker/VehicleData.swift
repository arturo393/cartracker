import Foundation

// MARK: - Vehicle Data Models

/// Representa los datos del vehículo leídos en tiempo real
@Observable
class VehicleData {
    var rpm: Int = 0
    var speed: Int = 0
    var engineTemp: Int = 0
    var fuelLevel: Double = 0.0
    var throttlePosition: Double = 0.0
    var engineLoad: Double = 0.0
    var maf: Double = 0.0 // Mass Air Flow
    var vin: String = ""
    var lastUpdate: Date = Date()
    var errorCodes: [DTCCode] = []
    
    // Estado de conexión
    var isConnected: Bool = false
    var connectionStatus: String = "Desconectado"
}

// MARK: - OBD-II PID Definitions

/// Definición de PIDs OBD-II Mode 01
enum OBDPIDMode01: UInt8, CaseIterable {
    case engineRPM = 0x0C
    case vehicleSpeed = 0x0D
    case engineCoolantTemp = 0x05
    case fuelLevel = 0x2F
    case throttlePosition = 0x11
    case engineLoad = 0x04
    case maf = 0x10
    case intakeAirTemp = 0x0F
    case fuelPressure = 0x0A
    case timingAdvance = 0x0E
    
    var description: String {
        switch self {
        case .engineRPM: return "Engine RPM"
        case .vehicleSpeed: return "Vehicle Speed"
        case .engineCoolantTemp: return "Engine Coolant Temperature"
        case .fuelLevel: return "Fuel Level"
        case .throttlePosition: return "Throttle Position"
        case .engineLoad: return "Engine Load"
        case .maf: return "Mass Air Flow"
        case .intakeAirTemp: return "Intake Air Temperature"
        case .fuelPressure: return "Fuel Pressure"
        case .timingAdvance: return "Timing Advance"
        }
    }
    
    var command: String {
        return String(format: "01%02X", self.rawValue)
    }
}

// MARK: - DTC (Diagnostic Trouble Codes)

/// Código de error de diagnóstico
struct DTCCode: Identifiable, Codable {
    let id = UUID()
    let code: String
    let description: String
    let severity: DTCSeverity
    let timestamp: Date
    
    enum DTCSeverity: String, Codable {
        case critical = "Crítico"
        case major = "Mayor"
        case minor = "Menor"
    }
    
    static let knownCodes: [String: (description: String, severity: DTCSeverity)] = [
        "P0300": ("Fallos de encendido aleatorios detectados", .major),
        "P0420": ("Eficiencia del catalizador por debajo del umbral", .major),
        "P0171": ("Sistema demasiado pobre (Banco 1)", .major),
        "P0172": ("Sistema demasiado rico (Banco 1)", .major),
        "P0401": ("Flujo de EGR insuficiente detectado", .minor),
        "P0442": ("Fuga pequeña en el sistema de evaporación", .minor),
        "P0128": ("Temperatura del refrigerante por debajo del termostato", .minor),
        "P0133": ("Respuesta lenta del sensor O2 (Banco 1, Sensor 1)", .minor),
    ]
    
    init(code: String) {
        self.code = code
        self.timestamp = Date()
        
        if let known = DTCCode.knownCodes[code] {
            self.description = known.description
            self.severity = known.severity
        } else {
            self.description = "Código de error desconocido"
            self.severity = .minor
        }
    }
}

// MARK: - OBD Command

/// Representa un comando OBD-II
struct OBDCommand {
    let mode: String
    let pid: String
    let expectedResponse: Int
    
    var fullCommand: String {
        return mode + pid
    }
    
    /// Comandos AT para inicialización de ELM327
    static let initCommands: [String] = [
        "ATZ",      // Reset
        "ATE0",     // Echo off
        "ATL0",     // Linefeeds off
        "ATS0",     // Spaces off
        "ATH0",     // Headers off
        "ATSP0",    // Auto protocol
    ]
    
    /// Comando para leer PIDs soportados
    static let supportedPIDs = OBDCommand(mode: "01", pid: "00", expectedResponse: 6)
    
    /// Comando para leer VIN
    static let readVIN = OBDCommand(mode: "09", pid: "02", expectedResponse: 20)
    
    /// Comando para leer DTCs
    static let readDTCs = OBDCommand(mode: "03", pid: "", expectedResponse: 0)
    
    /// Comando para borrar DTCs
    static let clearDTCs = OBDCommand(mode: "04", pid: "", expectedResponse: 0)
}

// MARK: - Response Parser

/// Parser para respuestas OBD-II
struct OBDResponseParser {
    
    /// Parsea la respuesta de RPM
    static func parseRPM(_ response: String) -> Int? {
        let bytes = extractBytes(from: response)
        guard bytes.count >= 2 else { return nil }
        return (bytes[0] * 256 + bytes[1]) / 4
    }
    
    /// Parsea la respuesta de velocidad
    static func parseSpeed(_ response: String) -> Int? {
        let bytes = extractBytes(from: response)
        guard bytes.count >= 1 else { return nil }
        return bytes[0]
    }
    
    /// Parsea la respuesta de temperatura
    static func parseTemperature(_ response: String) -> Int? {
        let bytes = extractBytes(from: response)
        guard bytes.count >= 1 else { return nil }
        return bytes[0] - 40
    }
    
    /// Parsea la respuesta de nivel de combustible
    static func parseFuelLevel(_ response: String) -> Double? {
        let bytes = extractBytes(from: response)
        guard bytes.count >= 1 else { return nil }
        return Double(bytes[0]) * 100.0 / 255.0
    }
    
    /// Parsea la respuesta de posición del acelerador
    static func parseThrottlePosition(_ response: String) -> Double? {
        let bytes = extractBytes(from: response)
        guard bytes.count >= 1 else { return nil }
        return Double(bytes[0]) * 100.0 / 255.0
    }
    
    /// Parsea la respuesta de carga del motor
    static func parseEngineLoad(_ response: String) -> Double? {
        let bytes = extractBytes(from: response)
        guard bytes.count >= 1 else { return nil }
        return Double(bytes[0]) * 100.0 / 255.0
    }
    
    /// Parsea la respuesta de MAF
    static func parseMAF(_ response: String) -> Double? {
        let bytes = extractBytes(from: response)
        guard bytes.count >= 2 else { return nil }
        return Double(bytes[0] * 256 + bytes[1]) / 100.0
    }
    
    /// Parsea códigos DTC
    static func parseDTCs(_ response: String) -> [DTCCode] {
        var codes: [DTCCode] = []
        let cleanResponse = response.replacingOccurrences(of: " ", with: "")
        
        // Los DTCs vienen en pares de bytes
        var index = cleanResponse.startIndex
        while index < cleanResponse.endIndex {
            let endIndex = cleanResponse.index(index, offsetBy: 4, limitedBy: cleanResponse.endIndex) ?? cleanResponse.endIndex
            let hexCode = String(cleanResponse[index..<endIndex])
            
            if let code = decodeDTC(hexCode) {
                codes.append(DTCCode(code: code))
            }
            
            index = endIndex
        }
        
        return codes
    }
    
    // MARK: - Helper Methods
    
    private static func extractBytes(from response: String) -> [Int] {
        let cleaned = response.replacingOccurrences(of: " ", with: "")
        var bytes: [Int] = []
        
        var index = cleaned.startIndex
        while index < cleaned.endIndex {
            let endIndex = cleaned.index(index, offsetBy: 2, limitedBy: cleaned.endIndex) ?? cleaned.endIndex
            let hexString = String(cleaned[index..<endIndex])
            
            if let byte = Int(hexString, radix: 16) {
                bytes.append(byte)
            }
            
            index = endIndex
        }
        
        return bytes
    }
    
    private static func decodeDTC(_ hex: String) -> String? {
        guard hex.count == 4, let value = Int(hex, radix: 16) else { return nil }
        
        if value == 0 { return nil }
        
        let firstDigit = (value >> 14) & 0x03
        let secondDigit = (value >> 12) & 0x03
        let thirdDigit = (value >> 8) & 0x0F
        let fourthDigit = (value >> 4) & 0x0F
        let fifthDigit = value & 0x0F
        
        let prefix: String
        switch firstDigit {
        case 0: prefix = "P0"
        case 1: prefix = "P1"
        case 2: prefix = "P2"
        case 3: prefix = "P3"
        default: prefix = "P0"
        }
        
        return String(format: "%@%X%X%X", prefix, thirdDigit, fourthDigit, fifthDigit)
    }
}
