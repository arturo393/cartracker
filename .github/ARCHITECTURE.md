# 🏗️ Arquitectura de CarTracker

Este documento describe la arquitectura técnica del proyecto CarTracker.

## 📋 Tabla de Contenidos

- [Visión General](#visión-general)
- [Arquitectura de Capas](#arquitectura-de-capas)
- [Componentes Principales](#componentes-principales)
- [Flujo de Datos](#flujo-de-datos)
- [Patrones de Diseño](#patrones-de-diseño)
- [Dependencias](#dependencias)

## Visión General

CarTracker es una aplicación iOS nativa construida con SwiftUI que permite leer datos de vehículos en tiempo real a través de un dispositivo ELM327 conectado vía Bluetooth al puerto OBD-II del vehículo.

### Stack Tecnológico

- **Lenguaje**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Plataforma Mínima**: iOS 17.0+
- **Bluetooth**: Core Bluetooth Framework
- **Arquitectura**: MVVM con Observable

## Arquitectura de Capas

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (SwiftUI Views & ViewModels)         │
├─────────────────────────────────────────┤
│         Business Logic Layer            │
│  (BluetoothManager, OBD Parsers)        │
├─────────────────────────────────────────┤
│           Data Layer                    │
│    (VehicleData Models, DTCs)           │
├─────────────────────────────────────────┤
│         Hardware Layer                  │
│  (Core Bluetooth, ELM327 Device)        │
└─────────────────────────────────────────┘
```

## Componentes Principales

### 1. Presentation Layer

#### ContentView.swift
- **Propósito**: Vista principal de la aplicación
- **Responsabilidades**:
  - Mostrar datos del vehículo en tiempo real
  - Gestionar navegación entre vistas
  - Presentar estado de conexión Bluetooth
- **Subvistas**:
  - `ConnectionHeaderView`: Cabecera con estado de conexión
  - `MainDataView`: Datos principales (RPM, velocidad, temperatura)
  - `SecondaryDataView`: Datos secundarios (combustible, acelerador, etc.)
  - `DeviceListView`: Lista de dispositivos Bluetooth
  - `DTCListView`: Lista de códigos de error

### 2. Business Logic Layer

#### BluetoothManager.swift
- **Propósito**: Gestionar toda la comunicación Bluetooth
- **Patrón**: Singleton Observable
- **Responsabilidades**:
  - Escanear dispositivos Bluetooth
  - Conectar/desconectar de ELM327
  - Enviar comandos OBD-II
  - Procesar respuestas del dispositivo
  - Inicializar ELM327 con comandos AT
  - Leer datos en tiempo real
  - Gestionar DTCs

**Propiedades Clave**:
```swift
@Observable class BluetoothManager {
    var discoveredDevices: [CBPeripheral]
    var isScanning: Bool
    var isConnected: Bool
    var vehicleData: VehicleData
}
```

**Métodos Principales**:
- `startScanning()`: Inicia búsqueda de dispositivos
- `connect(to:)`: Conecta a un dispositivo específico
- `sendCommand(_:completion:)`: Envía comando OBD-II
- `initializeELM327(completion:)`: Inicializa ELM327
- `readDTCs(completion:)`: Lee códigos de error

### 3. Data Layer

#### VehicleData.swift

**Modelos de Datos**:

1. **VehicleData** - Modelo principal de datos del vehículo
```swift
@Observable class VehicleData {
    var rpm: Int
    var speed: Int
    var engineTemp: Int
    var fuelLevel: Double
    var throttlePosition: Double
    var engineLoad: Double
    var maf: Double
    var isConnected: Bool
    var errorCodes: [DTCCode]
}
```

2. **OBDPIDMode01** - Definición de PIDs estándar
```swift
enum OBDPIDMode01: UInt8 {
    case engineRPM = 0x0C
    case vehicleSpeed = 0x0D
    case engineCoolantTemp = 0x05
    // ... más PIDs
}
```

3. **DTCCode** - Código de error de diagnóstico
```swift
struct DTCCode: Identifiable {
    let code: String
    let description: String
    let severity: DTCSeverity
    let timestamp: Date
}
```

4. **OBDResponseParser** - Parser de respuestas OBD-II
```swift
struct OBDResponseParser {
    static func parseRPM(_ response: String) -> Int?
    static func parseSpeed(_ response: String) -> Int?
    static func parseTemperature(_ response: String) -> Int?
    // ... más parsers
}
```

## Flujo de Datos

### 1. Conexión Inicial

```
Usuario toca "Conectar"
    ↓
ContentView presenta DeviceListView
    ↓
BluetoothManager.startScanning()
    ↓
Core Bluetooth descubre dispositivos
    ↓
Usuario selecciona dispositivo
    ↓
BluetoothManager.connect(to: peripheral)
    ↓
Descubrimiento de servicios y características
    ↓
BluetoothManager.initializeELM327()
    ↓
Envío de comandos AT (ATZ, ATE0, etc.)
    ↓
Conexión establecida
```

### 2. Lectura de Datos en Tiempo Real

```
Timer (cada 500ms)
    ↓
BluetoothManager.readAllPIDs()
    ↓
Para cada PID:
    sendCommand(pidCommand) { response in
        let parsedValue = Parser.parse(response)
        vehicleData.updateValue(parsedValue)
    }
    ↓
SwiftUI actualiza automáticamente la UI
(gracias a @Observable)
```

### 3. Comunicación OBD-II

```
App envía comando "010C\r"
    ↓
Bluetooth transmite a ELM327
    ↓
ELM327 consulta ECU del vehículo
    ↓
ECU responde con datos
    ↓
ELM327 formatea respuesta "41 0C 1F 40>"
    ↓
Bluetooth recibe datos
    ↓
Parser extrae bytes y aplica fórmula
    ↓
Valor actualizado en VehicleData
```

## Patrones de Diseño

### 1. MVVM (Model-View-ViewModel)
- **Model**: `VehicleData`, `DTCCode`, `OBDCommand`
- **View**: SwiftUI Views (`ContentView`, etc.)
- **ViewModel**: `BluetoothManager` (actúa como ViewModel)

### 2. Observable Pattern
Uso del nuevo macro `@Observable` de Swift 5.9:
```swift
@Observable class BluetoothManager {
    var isConnected: Bool = false
    // SwiftUI se suscribe automáticamente a cambios
}
```

### 3. Delegation Pattern
Core Bluetooth usa delegates:
- `CBCentralManagerDelegate`: Gestiona eventos del Central Manager
- `CBPeripheralDelegate`: Gestiona eventos del Peripheral

### 4. Command Pattern
`OBDCommand` encapsula comandos OBD-II:
```swift
struct OBDCommand {
    let mode: String
    let pid: String
    var fullCommand: String { mode + pid }
}
```

### 5. Strategy Pattern
Diferentes parsers para diferentes tipos de datos:
```swift
OBDResponseParser.parseRPM(response)
OBDResponseParser.parseSpeed(response)
OBDResponseParser.parseTemperature(response)
```

## Dependencias

### Nativas de iOS
- **CoreBluetooth**: Comunicación Bluetooth LE
- **SwiftUI**: Framework de UI declarativo
- **Foundation**: Tipos de datos fundamentales

### Futuras (Planeadas)
- **CoreData** o **SQLite**: Persistencia de datos
- **Charts**: Gráficos y visualizaciones
- **Combine**: Manejo reactivo de eventos

## Consideraciones de Rendimiento

### 1. Throttling de Comandos
- Delay de 100-500ms entre comandos OBD-II
- Evita saturar el bus CAN del vehículo
- Previene pérdida de datos

### 2. Background Execution
- Configurado en Info.plist: `UIBackgroundModes`
- Permite mantener conexión Bluetooth en background
- Limitado por iOS (10 segundos típicamente)

### 3. Memory Management
- Uso de `[weak self]` en closures
- Limpieza de buffers de datos recibidos
- Cancelación de timers al desconectar

## Seguridad y Privacidad

### 1. Permisos
- **Bluetooth**: Requiere autorización explícita del usuario
- Descripciones claras en Info.plist

### 2. Datos Sensibles
- No se almacenan credenciales
- Datos del vehículo permanecen en el dispositivo
- Sin conexión a servidores externos (por ahora)

## Testing

### Unit Tests
- Parsers OBD-II completamente testeados
- Validación de fórmulas de conversión
- Tests de modelos de datos

### Integration Tests (Futuro)
- Mock de dispositivo ELM327
- Simulación de respuestas OBD-II
- Tests de flujo completo

## Extensibilidad

### Agregar Nuevo PID
1. Añadir caso en `OBDPIDMode01`
2. Crear parser en `OBDResponseParser`
3. Agregar propiedad en `VehicleData`
4. Actualizar `readAllPIDs()` en `BluetoothManager`
5. Actualizar UI para mostrar nuevo dato

### Agregar Nueva Vista
1. Crear nueva SwiftUI View
2. Inyectar `BluetoothManager` como dependencia
3. Subscribirse a cambios con `@Bindable`
4. Agregar navegación desde `ContentView`

## Referencias

- [Core Bluetooth Programming Guide](https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/)
- [OBD-II PIDs Wikipedia](https://en.wikipedia.org/wiki/OBD-II_PIDs)
- [ELM327 Datasheet](https://www.elmelectronics.com/wp-content/uploads/2016/07/ELM327DS.pdf)
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)

---

**Última actualización**: 11 de octubre de 2025
