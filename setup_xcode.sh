#!/bin/bash

# 🚀 Script de Setup para CarTracker - Proyecto Xcode
# Este script crea un proyecto Xcode completo listo para ejecutar

set -e  # Exit on error

echo "🚀 CarTracker - Setup de Proyecto Xcode"
echo "========================================"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -d "Sources/cartracker" ]; then
    echo "❌ Error: Ejecuta este script desde la raíz del proyecto cartracker"
    exit 1
fi

# Verificar Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode no está instalado o no está en el PATH"
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -n 1)
echo "✅ $XCODE_VERSION encontrado"
echo ""

# Crear directorio para el proyecto Xcode
PROJECT_NAME="CarTrackerApp"
if [ -d "$PROJECT_NAME" ]; then
    echo "⚠️  El directorio $PROJECT_NAME ya existe"
    read -p "¿Deseas eliminarlo y recrearlo? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_NAME"
        echo "🗑️  Directorio eliminado"
    else
        echo "❌ Operación cancelada"
        exit 1
    fi
fi

echo "📁 Creando estructura de proyecto..."
mkdir -p "$PROJECT_NAME/$PROJECT_NAME"

# Copiar archivos Swift
echo "📋 Copiando archivos Swift..."
cp Sources/cartracker/App.swift "$PROJECT_NAME/$PROJECT_NAME/"
cp Sources/cartracker/BluetoothManager.swift "$PROJECT_NAME/$PROJECT_NAME/"
cp Sources/cartracker/ContentView.swift "$PROJECT_NAME/$PROJECT_NAME/"
cp Sources/cartracker/VehicleData.swift "$PROJECT_NAME/$PROJECT_NAME/"
cp Sources/cartracker/Info.plist "$PROJECT_NAME/$PROJECT_NAME/"

# Copiar assets adicionales
echo "📦 Configurando assets..."
cp README.md "$PROJECT_NAME/"
cp LICENSE "$PROJECT_NAME/"

# Crear archivo de configuración básica
cat > "$PROJECT_NAME/README.md" << 'EOF'
# CarTracker - Proyecto Xcode

Este proyecto fue generado automáticamente desde el paquete Swift.

## 🚀 Cómo Ejecutar

### Opción 1: Simulador (Solo UI)
1. Abre `CarTrackerApp.xcodeproj` en Xcode
2. Selecciona un simulador iOS
3. Presiona `Cmd+R`
4. **Nota**: Bluetooth no funcionará en simulador

### Opción 2: Dispositivo Físico (Recomendado)
1. Conecta tu iPhone/iPad
2. Abre el proyecto en Xcode
3. Selecciona tu dispositivo
4. Configura tu equipo en "Signing & Capabilities"
5. Presiona `Cmd+R`
6. Confía en el desarrollador en tu dispositivo (Settings → General → VPN & Device Management)

### Modo Demo (Sin ELM327)
La app incluye un modo demo que simula datos del vehículo:
- Actívalo desde la UI cuando no tengas un dispositivo ELM327

## 🔧 Configuración

### Permisos Bluetooth
El proyecto ya incluye los permisos necesarios en `Info.plist`:
- `NSBluetoothAlwaysUsageDescription`
- `NSBluetoothPeripheralUsageDescription`

### Background Modes
Configurado para usar Bluetooth en segundo plano.

## 📱 Requisitos
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Dispositivo iOS físico (para Bluetooth)

## 🧪 Testing
- Ejecuta tests con `Cmd+U` en Xcode
- O usa: `swift test` desde la terminal

## 📚 Documentación
Ver el directorio `.github/` para documentación completa:
- ARCHITECTURE.md
- CONTRIBUTING.md
- BUILD_GUIDE.md
EOF

echo ""
echo "✅ Proyecto base creado en: $PROJECT_NAME/"
echo ""
echo "📋 Próximos pasos:"
echo ""
echo "OPCIÓN A - Crear proyecto Xcode manualmente (Recomendado):"
echo "1. Abre Xcode"
echo "2. File → New → Project → iOS → App"
echo "3. Nombre: CarTracker"
echo "4. Interfaz: SwiftUI"
echo "5. Arrastra los archivos de $PROJECT_NAME/$PROJECT_NAME/ al proyecto"
echo "6. Copia el contenido de Info.plist a tu proyecto"
echo "7. En Signing & Capabilities, agrega 'Background Modes' y marca 'Uses Bluetooth LE accessories'"
echo ""
echo "OPCIÓN B - Usar herramienta de Xcode (Experimental):"
echo "cd $PROJECT_NAME && swift package init --type executable --name $PROJECT_NAME"
echo ""
echo "⚡ Tip: Para testing rápido sin hardware, la app incluye modo demo"
echo ""
