import Foundation
import CoreBluetooth

// MARK: - Bluetooth Manager

/// Manager para manejar la conexión Bluetooth con el dispositivo ELM327
@Observable
class BluetoothManager: NSObject {
    
    // MARK: - Properties
    
    private var centralManager: CBCentralManager!
    private var elm327Peripheral: CBPeripheral?
    private var elm327Characteristic: CBCharacteristic?
    
    var discoveredDevices: [CBPeripheral] = []
    var isScanning: Bool = false
    var isConnected: Bool = false
    var connectionStatus: String = "Desconectado"
    
    var vehicleData = VehicleData()
    
    private var receivedData = Data()
    private var pendingCommand: String?
    private var commandCompletion: ((String?) -> Void)?
    
    // UUIDs comunes para ELM327 (pueden variar según el dispositivo)
    private let serviceUUID = CBUUID(string: "FFE0")
    private let characteristicUUID = CBUUID(string: "FFE1")
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Public Methods
    
    /// Inicia el escaneo de dispositivos Bluetooth
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            connectionStatus = "Bluetooth no disponible"
            return
        }
        
        discoveredDevices.removeAll()
        isScanning = true
        connectionStatus = "Buscando dispositivos..."
        
        // Escanear todos los dispositivos (ELM327 puede no anunciar servicios)
        centralManager.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
    }
    
    /// Detiene el escaneo de dispositivos
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }
    
    /// Conecta a un dispositivo específico
    func connect(to peripheral: CBPeripheral) {
        stopScanning()
        elm327Peripheral = peripheral
        peripheral.delegate = self
        connectionStatus = "Conectando..."
        centralManager.connect(peripheral, options: nil)
    }
    
    /// Desconecta del dispositivo actual
    func disconnect() {
        guard let peripheral = elm327Peripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
        isConnected = false
        connectionStatus = "Desconectado"
        vehicleData.isConnected = false
    }
    
    /// Envía un comando al dispositivo ELM327
    func sendCommand(_ command: String, completion: @escaping (String?) -> Void) {
        guard let characteristic = elm327Characteristic,
              let peripheral = elm327Peripheral else {
            completion(nil)
            return
        }
        
        pendingCommand = command
        commandCompletion = completion
        receivedData = Data()
        
        let commandData = (command + "\r").data(using: .ascii)!
        peripheral.writeValue(commandData, for: characteristic, type: .withResponse)
    }
    
    /// Inicializa la conexión con ELM327
    func initializeELM327(completion: @escaping (Bool) -> Void) {
        var commandIndex = 0
        let commands = OBDCommand.initCommands
        
        func sendNextCommand() {
            guard commandIndex < commands.count else {
                completion(true)
                return
            }
            
            let command = commands[commandIndex]
            sendCommand(command) { response in
                if response != nil {
                    commandIndex += 1
                    // Pequeño delay entre comandos
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        sendNextCommand()
                    }
                } else {
                    completion(false)
                }
            }
        }
        
        sendNextCommand()
    }
    
    /// Lee los datos del vehículo en tiempo real
    func startReadingVehicleData() {
        guard isConnected else { return }
        
        // Leer datos cada 500ms
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, self.isConnected else {
                timer.invalidate()
                return
            }
            
            self.readAllPIDs()
        }
    }
    
    // MARK: - Private Methods
    
    private func readAllPIDs() {
        // Leer RPM
        sendCommand(OBDPIDMode01.engineRPM.command) { [weak self] response in
            if let response = response, let rpm = OBDResponseParser.parseRPM(response) {
                self?.vehicleData.rpm = rpm
            }
        }
        
        // Leer velocidad
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.sendCommand(OBDPIDMode01.vehicleSpeed.command) { response in
                if let response = response, let speed = OBDResponseParser.parseSpeed(response) {
                    self?.vehicleData.speed = speed
                }
            }
        }
        
        // Leer temperatura
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.sendCommand(OBDPIDMode01.engineCoolantTemp.command) { response in
                if let response = response, let temp = OBDResponseParser.parseTemperature(response) {
                    self?.vehicleData.engineTemp = temp
                }
            }
        }
        
        // Leer nivel de combustible
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.sendCommand(OBDPIDMode01.fuelLevel.command) { response in
                if let response = response, let fuel = OBDResponseParser.parseFuelLevel(response) {
                    self?.vehicleData.fuelLevel = fuel
                }
            }
        }
        
        // Leer posición del acelerador
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.sendCommand(OBDPIDMode01.throttlePosition.command) { response in
                if let response = response, let throttle = OBDResponseParser.parseThrottlePosition(response) {
                    self?.vehicleData.throttlePosition = throttle
                }
            }
        }
        
        vehicleData.lastUpdate = Date()
    }
    
    /// Lee códigos de error DTC
    func readDTCs(completion: @escaping ([DTCCode]) -> Void) {
        sendCommand(OBDCommand.readDTCs.fullCommand) { response in
            if let response = response {
                let codes = OBDResponseParser.parseDTCs(response)
                completion(codes)
            } else {
                completion([])
            }
        }
    }
    
    /// Borra códigos de error DTC
    func clearDTCs(completion: @escaping (Bool) -> Void) {
        sendCommand(OBDCommand.clearDTCs.fullCommand) { response in
            completion(response != nil)
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            connectionStatus = "Bluetooth disponible"
        case .poweredOff:
            connectionStatus = "Bluetooth apagado"
        case .unauthorized:
            connectionStatus = "Bluetooth no autorizado"
        case .unsupported:
            connectionStatus = "Bluetooth no soportado"
        default:
            connectionStatus = "Estado desconocido"
        }
    }
    
    func centralManager(_ central: CBCentralManager, 
                       didDiscover peripheral: CBPeripheral,
                       advertisementData: [String : Any], 
                       rssi RSSI: NSNumber) {
        
        // Filtrar dispositivos por nombre (ELM327, OBD, etc.)
        let deviceName = peripheral.name ?? "Desconocido"
        if deviceName.contains("ELM") || 
           deviceName.contains("OBD") || 
           deviceName.contains("OBDII") ||
           deviceName.contains("CHX") {
            
            if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                discoveredDevices.append(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, 
                       didConnect peripheral: CBPeripheral) {
        connectionStatus = "Conectado - Descubriendo servicios..."
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, 
                       didFailToConnect peripheral: CBPeripheral, 
                       error: Error?) {
        connectionStatus = "Error al conectar: \(error?.localizedDescription ?? "desconocido")"
        isConnected = false
    }
    
    func centralManager(_ central: CBCentralManager, 
                       didDisconnectPeripheral peripheral: CBPeripheral, 
                       error: Error?) {
        isConnected = false
        connectionStatus = "Desconectado"
        vehicleData.isConnected = false
        elm327Peripheral = nil
        elm327Characteristic = nil
    }
}

// MARK: - CBPeripheralDelegate

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, 
                   didDiscoverServices error: Error?) {
        guard error == nil else {
            connectionStatus = "Error al descubrir servicios"
            return
        }
        
        // Buscar el servicio principal
        if let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) {
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        } else {
            // Si no encontramos el servicio específico, buscar en todos
            peripheral.services?.forEach { service in
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, 
                   didDiscoverCharacteristicsFor service: CBService, 
                   error: Error?) {
        guard error == nil else {
            connectionStatus = "Error al descubrir características"
            return
        }
        
        // Buscar la característica de lectura/escritura
        if let characteristic = service.characteristics?.first(where: { 
            $0.uuid == characteristicUUID
        }) {
            elm327Characteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
            
            isConnected = true
            vehicleData.isConnected = true
            connectionStatus = "Conectado - Inicializando ELM327..."
            
            // Inicializar ELM327
            initializeELM327 { [weak self] success in
                if success {
                    self?.connectionStatus = "Conectado y listo"
                    self?.startReadingVehicleData()
                } else {
                    self?.connectionStatus = "Error al inicializar ELM327"
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, 
                   didUpdateValueFor characteristic: CBCharacteristic, 
                   error: Error?) {
        guard error == nil, let data = characteristic.value else { return }
        
        receivedData.append(data)
        
        // Verificar si hemos recibido una respuesta completa (termina con '>' o '\r')
        if let response = String(data: receivedData, encoding: .ascii) {
            if response.contains(">") || response.contains("\r") {
                // Limpiar la respuesta
                let cleanedResponse = response
                    .replacingOccurrences(of: ">", with: "")
                    .replacingOccurrences(of: "\r", with: "")
                    .replacingOccurrences(of: "\n", with: "")
                    .trimmingCharacters(in: .whitespaces)
                
                // Llamar al completion handler
                commandCompletion?(cleanedResponse)
                commandCompletion = nil
                pendingCommand = nil
                receivedData = Data()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, 
                   didWriteValueFor characteristic: CBCharacteristic, 
                   error: Error?) {
        if let error = error {
            print("Error al escribir: \(error.localizedDescription)")
            commandCompletion?(nil)
            commandCompletion = nil
        }
    }
}
