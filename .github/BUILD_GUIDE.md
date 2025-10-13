# 🚀 Guía de Construcción y Ejecución - CarTracker

## 📱 Opciones para Probar la App

### Opción 1: Simulador de iOS (Sin Bluetooth) ⚠️
**Limitación**: El simulador de iOS **NO soporta Bluetooth**, por lo que no podrás probar la conexión real con ELM327.

**Ventajas**:
- Puedes ver la UI
- Probar navegación
- Verificar que la app compile

### Opción 2: Dispositivo iOS Físico (Recomendado) ✅
**Requerido para**:
- Probar conexión Bluetooth real
- Conectar con ELM327
- Testing completo de funcionalidad

### Opción 3: Mac Catalyst (macOS) ⚠️
**Limitado**: Bluetooth puede funcionar pero con limitaciones

---

## 🛠️ Construcción con Swift Package Manager

### Paso 1: Verificar Prerrequisitos

```bash
# Verificar versión de Swift
swift --version
# Debe ser Swift 5.9 o superior

# Verificar Xcode
xcodebuild -version
# Debe ser Xcode 15.0 o superior
```

### Paso 2: Construir el Proyecto

```bash
cd /Users/arturo/development/GitHub/cartracker

# Compilar el proyecto
swift build

# Ver errores detallados (si los hay)
swift build -v
```

**Nota**: Probablemente verás un error porque Swift Package Manager solo no puede construir aplicaciones iOS directamente. Necesitas usar Xcode.

---

## 🎯 Construcción con Xcode (Recomendado)

### Opción A: Crear Proyecto Xcode Manualmente

#### 1. Crear un Nuevo Proyecto de App iOS

```bash
# Desde tu directorio de proyecto
cd /Users/arturo/development/GitHub/cartracker
```

1. Abre Xcode
2. File → New → Project
3. Selecciona "iOS" → "App"
4. Configura:
   - **Product Name**: CarTracker
   - **Team**: Tu cuenta de desarrollador
   - **Organization Identifier**: com.arturo393
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None
5. Guárdalo en una carpeta temporal (no en el repo)

#### 2. Copiar Archivos del Proyecto

Necesitas mover los archivos Swift del proyecto SPM al proyecto Xcode:

```bash
# Los archivos están en:
Sources/cartracker/
├── App.swift
├── BluetoothManager.swift
├── ContentView.swift
├── Info.plist
└── VehicleData.swift
```

#### 3. Importar a Xcode

1. En Xcode, borra los archivos de plantilla (ContentView.swift, etc.)
2. Arrastra los archivos desde `Sources/cartracker/` al proyecto
3. Asegúrate de marcar "Copy items if needed"
4. Selecciona "Create groups"

#### 4. Configurar Info.plist

1. En Xcode, abre Info.plist
2. Agrega las claves de Bluetooth:
   - `NSBluetoothAlwaysUsageDescription`
   - `NSBluetoothPeripheralUsageDescription`
3. O copia el contenido del `Info.plist` del repo

#### 5. Configurar Capabilities

1. Selecciona el proyecto en Xcode
2. Ve a "Signing & Capabilities"
3. Agrega "Background Modes"
4. Marca "Uses Bluetooth LE accessories"

### Opción B: Usar Xcode CLI para Generar Proyecto

```bash
cd /Users/arturo/development/GitHub/cartracker

# Generar proyecto Xcode desde Package.swift
swift package generate-xcodeproj
```

**Problema**: Esto genera un framework, no una app. Necesitarás crear un target de aplicación manualmente.

---

## 🏃 Ejecutar la App

### En Simulador (UI solamente)

1. Abre el proyecto en Xcode
2. Selecciona un simulador (iPhone 15 Pro, etc.)
3. Presiona `Cmd+R` o clic en "Run"
4. La app se abrirá pero Bluetooth no funcionará

### En Dispositivo Físico

1. Conecta tu iPhone/iPad con cable USB
2. En Xcode, selecciona tu dispositivo
3. Ve a "Signing & Capabilities"
4. Selecciona tu equipo de desarrollo
5. Presiona `Cmd+R`
6. **Primera vez**: Debes confiar en el desarrollador en el dispositivo
   - Settings → General → VPN & Device Management → Trust

---

## 🧪 Testing sin Hardware ELM327

### Crear Mock de Bluetooth Manager

Puedes crear un modo de demostración que simule datos:

```swift
// En BluetoothManager.swift, agrega:
var isDemoMode: Bool = false

func startDemoMode() {
    isDemoMode = true
    isConnected = true
    connectionStatus = "Demo Mode"
    vehicleData.isConnected = true
    
    // Simular datos
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
        self.vehicleData.rpm = Int.random(in: 800...6000)
        self.vehicleData.speed = Int.random(in: 0...120)
        self.vehicleData.engineTemp = Int.random(in: 70...95)
        self.vehicleData.fuelLevel = Double.random(in: 20...100)
        // ...más datos simulados
    }
}
```

---

## 📝 Script de Configuración Rápida

Voy a crear un script que automatice la configuración:

```bash
#!/bin/bash
# setup_xcode_project.sh

echo "🚀 Configurando proyecto CarTracker para Xcode..."

# Verificar Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode no está instalado"
    exit 1
fi

# Crear directorio para proyecto Xcode
mkdir -p CarTrackerApp
cd CarTrackerApp

# Crear estructura de proyecto
mkdir -p CarTrackerApp
cp -r ../Sources/cartracker/* CarTrackerApp/

echo "✅ Archivos copiados"
echo "📋 Siguiente paso:"
echo "1. Abre Xcode"
echo "2. File → New → Project → iOS App"
echo "3. Arrastra los archivos de CarTrackerApp/ al proyecto"
echo "4. Configura Bluetooth permissions en Info.plist"
echo "5. ¡Ejecuta!"
```

---

## 🔧 Alternativa: Proyecto Xcode Completo

¿Quieres que cree un proyecto Xcode completo en el repositorio? Esto incluiría:
- Archivo `.xcodeproj`
- Configuración de capabilities
- Targets configurados
- Todo listo para abrir y ejecutar

---

## ⚡ Solución Rápida para Testing

Para probar **solo la UI** sin Bluetooth:

1. Abre Xcode
2. File → New → Playground
3. Importa SwiftUI
4. Copia ContentView.swift
5. Agrega datos mock

```swift
import SwiftUI
import PlaygroundSupport

// Mock del BluetoothManager
class MockBluetoothManager: ObservableObject {
    @Published var isConnected = true
    @Published var vehicleData = VehicleData()
    
    init() {
        vehicleData.rpm = 2000
        vehicleData.speed = 80
        vehicleData.engineTemp = 90
    }
}

// Tu ContentView aquí...

PlaygroundPage.current.setLiveView(ContentView())
```

---

## 🎯 Recomendación

**Para desarrollo serio**, lo mejor es:

1. ✅ Crear un proyecto Xcode nativo
2. ✅ Usar tu iPhone físico para testing
3. ✅ Tener un dispositivo ELM327 para pruebas reales

**¿Quieres que te ayude a?**
- [ ] Crear un proyecto Xcode completo en el repo
- [ ] Configurar modo demo/mock para testing
- [ ] Crear un script de setup automático
- [ ] Convertir a app macOS con Mac Catalyst
