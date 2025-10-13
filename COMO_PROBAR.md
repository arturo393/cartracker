# 📱 Cómo Probar CarTracker desde tu MacBook

## 🎯 Resumen Ejecutivo

**Situación actual**: Tienes el código de CarTracker pero necesitas Xcode completo para ejecutar la app iOS.

**Solución rápida**: Instala Xcode → Crea proyecto iOS → Usa Modo Demo para probar sin hardware

---

## 🚀 Opción 1: Testing Rápido con Modo Demo (Recomendado)

### Paso 1: Instalar Xcode (Si no lo tienes)

```bash
# Verificar si tienes Xcode
xcodebuild -version
```

Si no está instalado:
1. Abre **App Store**
2. Busca "Xcode"
3. Descarga (⚠️ ~15 GB, tarda un rato)
4. Después de instalar:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

### Paso 2: Crear Proyecto Xcode

**Opción A - Automática con script:**

```bash
cd /Users/arturo/development/GitHub/cartracker
./setup_xcode.sh
```

**Opción B - Manual en Xcode:**

1. Abre Xcode
2. `File → New → Project`
3. Selecciona: `iOS → App`
4. Configura:
   - **Product Name**: CarTracker
   - **Team**: Tu cuenta
   - **Organization Identifier**: com.arturo393
   - **Interface**: SwiftUI
   - **Language**: Swift
5. Guarda en una carpeta temporal

### Paso 3: Importar el Código

1. En Xcode, borra los archivos plantilla (ContentView.swift, etc.)
2. Arrastra estos archivos al proyecto:
   ```
   Sources/cartracker/App.swift
   Sources/cartracker/BluetoothManager.swift
   Sources/cartracker/ContentView.swift
   Sources/cartracker/VehicleData.swift
   ```
3. Marca "Copy items if needed"

### Paso 4: Configurar Permisos Bluetooth

En Xcode, abre `Info` tab y agrega:

- **Key**: `Privacy - Bluetooth Always Usage Description`
  **Value**: `CarTracker necesita Bluetooth para conectar con el dispositivo OBD-II`

- **Key**: `Privacy - Bluetooth Peripheral Usage Description`
  **Value**: `Permite leer datos del vehículo vía Bluetooth`

O copia el contenido del archivo `Sources/cartracker/Info.plist`

### Paso 5: Configurar Background Modes

1. Selecciona el target "CarTracker"
2. Ve a `Signing & Capabilities`
3. Clic en `+ Capability`
4. Busca y agrega `Background Modes`
5. Marca: `☑️ Uses Bluetooth LE accessories`

### Paso 6: Ejecutar en Simulador

```bash
# Desde Xcode: Cmd+R con iPhone 15 Pro seleccionado
```

O desde terminal:
```bash
xcodebuild -scheme CarTracker \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  run
```

### Paso 7: Activar Modo Demo

⚠️ **Importante**: El simulador NO soporta Bluetooth real

1. La app se abrirá mostrando "Desconectado"
2. Presiona el botón **"Modo Demo (Sin Hardware)"**
3. 🎉 ¡La app mostrará datos simulados realistas!

**Datos que verás**:
- RPM: 800-6000 (variable)
- Velocidad: 0-120 km/h
- Temperatura: Se calienta de 0 a 90°C
- Combustible: Baja gradualmente
- Carga del motor, MAF, posición del acelerador
- Ocasionalmente muestra códigos DTC simulados

---

## 📱 Opción 2: Testing Real en iPhone/iPad (Para Bluetooth Real)

### Requisitos
- iPhone o iPad con iOS 17+
- Cable USB

### Pasos

1. Sigue los pasos 1-5 de la Opción 1
2. Conecta tu iPhone/iPad con cable USB
3. En Xcode, selecciona tu dispositivo (arriba a la izquierda)
4. Ve a `Signing & Capabilities`:
   - Selecciona tu equipo (Apple ID)
   - O activa "Automatically manage signing"
5. Presiona `Cmd+R` para instalar

**Primera vez**:
- En tu dispositivo: `Settings → General → VPN & Device Management`
- Encuentra tu desarrollador
- Presiona "Trust"

**Ahora puedes**:
- Probar Bluetooth real
- Buscar dispositivos ELM327
- Conectar a tu auto (si tienes ELM327)
- O usar Modo Demo

---

## 🛠️ Opción 3: Solo Compilar y Ver Tests (Sin Ejecutar App)

Si solo quieres verificar que el código funciona:

```bash
cd /Users/arturo/development/GitHub/cartracker

# Ver comandos disponibles
make help

# Compilar (como biblioteca)
make build

# Ejecutar tests
make test

# Ver cobertura de tests
make coverage

# Limpiar
make clean
```

**Nota**: Esto NO ejecuta la app, solo verifica el código.

---

## 🎭 Modo Demo - Características

El modo demo simula un vehículo funcionando de manera realista:

### Datos Simulados

| Métrica | Comportamiento |
|---------|----------------|
| **RPM** | Varía entre 800-6000, simulando aceleración |
| **Velocidad** | 0-120 km/h con variaciones realistas |
| **Temperatura** | Se calienta gradualmente de 0 a 90°C |
| **Combustible** | Baja lentamente de 100% a 20% |
| **Carga Motor** | 20-60% variable |
| **MAF** | 3-15 g/s |
| **Acelerador** | 10-45% |
| **DTCs** | Aparecen ocasionalmente (P0420, P0171) |

### Activación

```swift
// En código
bluetoothManager.startDemoMode()

// En UI
Presiona: "Modo Demo (Sin Hardware)"

// Para detener
bluetoothManager.stopDemoMode()
```

---

## 📚 Archivos de Referencia

| Archivo | Descripción |
|---------|-------------|
| `QUICK_START.md` | Guía completa de instalación |
| `.github/BUILD_GUIDE.md` | Opciones de construcción detalladas |
| `.github/ARCHITECTURE.md` | Arquitectura del proyecto |
| `Makefile` | Comandos útiles |
| `setup_xcode.sh` | Script de setup automático |

---

## 🐛 Problemas Comunes

### "Command line tools are not installed"
```bash
xcode-select --install
```

### "Unable to find utility xctest"
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### "Signing requires a development team"
1. Xcode → Settings → Accounts
2. Agrega tu Apple ID
3. O marca "Automatically manage signing"

### "No simulators available"
```bash
# Instalar simuladores
xcodebuild -downloadPlatform iOS
```

---

## 📊 Comparación de Opciones

| Método | Xcode | Bluetooth | Ver UI | Dificultad | Tiempo |
|--------|-------|-----------|--------|------------|--------|
| Modo Demo (Simulador) | ✅ | ❌ | ✅ | Fácil | 30 min |
| Dispositivo Físico | ✅ | ✅ | ✅ | Media | 45 min |
| Solo Tests | ❌ | ❌ | ❌ | Muy Fácil | 5 min |

---

## 🎯 Mi Recomendación Para Ti

### Plan A: Testing Completo (Recomendado)
1. ✅ Instala Xcode (hoy, mientras haces otra cosa)
2. ✅ Crea proyecto iOS en Xcode (15 min)
3. ✅ Ejecuta en simulador con Modo Demo (inmediato)
4. ✅ Si tienes iPhone, instala ahí para probar Bluetooth real

### Plan B: Verificación Rápida (Sin Xcode)
1. ✅ Ejecuta: `make test` para ver tests (5 min)
2. ✅ Lee el código en tu editor favorito
3. ✅ Instala Xcode después

---

## 🆘 Necesitas Ayuda?

1. **Documentación**: Lee `QUICK_START.md` para más detalles
2. **Comandos**: Ejecuta `make help`
3. **Issues**: Reporta problemas en GitHub

---

## ✅ Checklist de Éxito

- [ ] Xcode instalado
- [ ] Proyecto CarTracker creado en Xcode
- [ ] Archivos Swift importados
- [ ] Permisos Bluetooth configurados
- [ ] Background Modes habilitado
- [ ] App ejecutándose en simulador
- [ ] Modo Demo activado
- [ ] Viendo datos en tiempo real

**¡Cuando completes esto, estarás viendo tu app funcionando! 🎉**

---

**Siguiente paso**: Instala Xcode y empieza por `./setup_xcode.sh` 🚀
