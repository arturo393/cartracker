# 🚀 Guía de Instalación Rápida - CarTracker en macOS

## ⚠️ Situación Actual

Detectamos que tienes **Command Line Tools** pero no **Xcode completo**. Para desarrollar y probar apps iOS, necesitas Xcode completo.

## 📥 Instalación de Xcode

### Opción 1: App Store (Recomendado)

1. Abre **App Store**
2. Busca "Xcode"
3. Descarga e instala (⚠️ ~15 GB, puede tardar)
4. Abre Xcode una vez para completar la instalación
5. Acepta la licencia

```bash
# Después de instalar, configura las command line tools:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

### Opción 2: Manual desde Apple Developer

1. Ve a [developer.apple.com/download](https://developer.apple.com/download)
2. Descarga Xcode
3. Mueve a `/Applications/`
4. Configura:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

## ✅ Verificación Post-Instalación

```bash
# Verificar Xcode
xcodebuild -version
# Debería mostrar: Xcode 15.x o superior

# Verificar Swift
swift --version
# Debería mostrar: Swift 5.9 o superior

# Verificar simuladores
xcrun simctl list devices
```

## 🎯 Cómo Ejecutar CarTracker Después de Instalar Xcode

### Paso 1: Abrir el Proyecto

```bash
cd /Users/arturo/development/GitHub/cartracker
open -a Xcode .
```

O desde Xcode:
1. File → Open
2. Selecciona la carpeta `cartracker`
3. Xcode detectará el `Package.swift`

### Paso 2: Crear un Target de Aplicación iOS

Como este es un Swift Package, necesitas crear un target de app:

#### Método A: Usando el script automatizado

```bash
./setup_xcode.sh
```

Luego en Xcode:
1. File → New → Project
2. iOS → App
3. Nombre: CarTracker
4. Arrastra los archivos de `CarTrackerApp/CarTrackerApp/` al proyecto

#### Método B: Manual en Xcode

1. En Xcode, con el Package.swift abierto
2. File → New → Target
3. Selecciona "App" (iOS)
4. Configura:
   - Product Name: CarTracker
   - Interface: SwiftUI
   - Language: Swift
5. Arrastra los archivos Swift desde `Sources/cartracker/` al nuevo target

### Paso 3: Configurar Permisos

1. Selecciona el target CarTracker
2. Abre `Info.plist` o la pestaña "Info"
3. Agrega:
   - `Privacy - Bluetooth Always Usage Description`: "CarTracker necesita Bluetooth para conectar con el dispositivo OBD-II"
   - `Privacy - Bluetooth Peripheral Usage Description`: "Permite leer datos del vehículo vía Bluetooth"

### Paso 4: Configurar Capabilities

1. Selecciona el proyecto en el navegador
2. Target → Signing & Capabilities
3. Signing:
   - Selecciona tu equipo
   - O usa "Automatically manage signing"
4. Agrega capability "Background Modes":
   - Marca "Uses Bluetooth LE accessories"

### Paso 5: Ejecutar

#### En Simulador (Solo UI, sin Bluetooth):
```bash
# Opción 1: Desde Xcode
Cmd+R con simulador seleccionado

# Opción 2: Desde terminal
xcodebuild -scheme CarTracker -destination 'platform=iOS Simulator,name=iPhone 15 Pro' run
```

⚠️ **Limitación**: El simulador NO soporta Bluetooth. Usa el **Modo Demo** para ver la UI.

#### En Dispositivo Físico (Recomendado):
1. Conecta tu iPhone/iPad con USB
2. Selecciona el dispositivo en Xcode
3. Presiona `Cmd+R`
4. Primera vez: Ve a Settings → General → VPN & Device Management → Trust

## 🎭 Modo Demo (Sin Hardware ELM327)

La app incluye un modo de demostración que simula datos realistas:

1. Ejecuta la app (simulador o dispositivo)
2. Presiona **"Modo Demo (Sin Hardware)"**
3. La app mostrará datos simulados:
   - RPM variables (800-6000)
   - Velocidad (0-120 km/h)
   - Temperatura del motor
   - Nivel de combustible
   - Y más...

## 📱 Alternativas Mientras Instalas Xcode

### Opción 1: Verificar el Código (Sin Ejecutar)

```bash
# Compilar como biblioteca (no app)
swift build

# Ejecutar tests
make test

# Ver estructura
swift package describe
```

### Opción 2: Ver la UI en Swift Playground

1. Abre Xcode
2. File → New → Playground
3. Selecciona "Blank" (iOS)
4. Copia el código de `ContentView.swift`
5. Crea mocks:

```swift
import SwiftUI
import PlaygroundSupport

// Mock classes
@Observable
class VehicleData {
    var rpm: Int = 2000
    var speed: Int = 80
    var engineTemp: Int = 90
    var fuelLevel: Double = 75.0
    var isConnected = true
    // ... más propiedades
}

@Observable
class BluetoothManager {
    var isConnected = true
    var connectionStatus = "Demo Mode"
    var vehicleData = VehicleData()
    var isDemoMode = true
    
    func startDemoMode() {}
    func stopDemoMode() {}
}

// Pega aquí el ContentView

PlaygroundPage.current.setLiveView(
    ContentView()
        .frame(width: 375, height: 812)
)
```

## 🔧 Solución de Problemas Comunes

### Error: "xcrun: error: unable to find utility"

**Causa**: Solo tienes Command Line Tools, no Xcode completo

**Solución**: Instala Xcode completo desde App Store

### Error: "Unable to boot simulator"

**Causa**: Los simuladores no están instalados

**Solución**:
```bash
# Instalar simuladores iOS
xcodebuild -downloadAllPlatforms
```

### Error: "Signing for CarTracker requires a development team"

**Causa**: No has configurado tu cuenta de desarrollador

**Solución**:
1. Xcode → Settings → Accounts
2. Agrega tu Apple ID
3. O usa "Automatically manage signing"

### Error: "Could not find or use auto-linked library"

**Causa**: Dependencias no están linkeadas correctamente

**Solución**:
1. Project → Build Phases
2. Link Binary With Libraries
3. Agrega CoreBluetooth.framework

## 📊 Resumen de Opciones

| Opción | Requiere Xcode | Prueba Bluetooth | Dificultad |
|--------|---------------|------------------|------------|
| Simulador iOS | ✅ | ❌ | Fácil |
| Dispositivo iOS | ✅ | ✅ | Media |
| Modo Demo | ✅ | ❌ (simulado) | Fácil |
| Swift Playground | ✅ | ❌ | Fácil |
| Compilar como lib | ❌ | ❌ | Fácil |

## 🎯 Recomendación

1. **Instala Xcode** desde App Store (hoy)
2. **Mientras se instala**:
   - Ejecuta `make test` para ver los tests
   - Revisa la documentación en `.github/`
   - Explora el código en tu editor favorito
3. **Después de instalar**:
   - Crea el proyecto iOS en Xcode
   - Prueba en simulador con Modo Demo
   - Si tienes iPhone, prueba en dispositivo real
   - Si tienes ELM327, conecta a tu auto

## 🆘 ¿Necesitas Ayuda?

- **Documentación**: `.github/BUILD_GUIDE.md`
- **Arquitectura**: `.github/ARCHITECTURE.md`
- **Issues**: https://github.com/arturo393/cartracker/issues
- **Comandos útiles**: `make help`

---

**Siguiente paso**: Instala Xcode y regresa a esta guía 🚀
