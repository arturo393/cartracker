# 🚗 CarTracker

Una aplicación iOS para leer y almacenar datos de vehículos en tiempo real utilizando el lector ELM327 conectado al puerto OBD-II mediante Bluetooth.

> **🚀 NUEVO**: Incluye **Modo Demo** para probar sin hardware ELM327
> 
> **📱 ¿Quieres probar la app?** Lee la [Guía de Prueba](COMO_PROBAR.md) para instrucciones paso a paso

## 📋 Descripción

CarTracker permite monitorear los datos del vehículo en tiempo real, almacenarlos en una base de datos local y visualizarlos de manera intuitiva. El proyecto incluye soporte para ingeniería inversa de PIDs propietarios de diferentes fabricantes.

## ✨ Características

- 🔵 **Conexión Bluetooth**: Comunicación con dispositivos ELM327
- 📊 **Datos en tiempo real**: Lectura continua de parámetros del vehículo
- 💾 **Almacenamiento persistente**: Base de datos Core Data para histórico completo
- 📈 **Histórico y estadísticas**: Análisis detallado de rendimiento del vehículo
- 📊 **Exportación de datos**: CSV con todos los datos históricos
- 🚗 **Gestión de viajes**: Seguimiento automático de viajes individuales
- 📈 **Visualización**: Gráficos y medidores intuitivos
- 🔧 **Códigos de error (DTC)**: Lectura y decodificación de diagnósticos
- 🔍 **PIDs extendidos**: Soporte para comandos propietarios de fabricantes

## 📱 Requisitos

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Dispositivo ELM327 compatible con Bluetooth

## 🏗️ Arquitectura

```
cartracker/
├── Sources/
│   └── cartracker/
│       ├── App.swift              # Punto de entrada de la app
│       ├── ContentView.swift      # Vista principal
│       ├── BluetoothManager.swift # Gestión de conexión Bluetooth
│       └── VehicleData.swift      # Modelos de datos del vehículo
├── Tests/
│   └── cartrackerTests/
└── Package.swift
```

## 🚀 Roadmap

### Fase 1: Conexión básica
- [x] Estructura del proyecto
- [ ] Conexión Bluetooth con ELM327
- [ ] Lectura de PIDs básicos (RPM, velocidad, temperatura)
- [ ] Parseo de respuestas AT commands

### Fase 2: Almacenamiento
- [x] Diseño de esquema de base de datos (Core Data)
- [x] Implementación de capa de persistencia
- [x] Histórico de datos con filtros y búsqueda
- [x] Gestión automática de viajes
- [x] Estadísticas detalladas del vehículo
- [x] Exportación de datos a CSV

### Fase 3: Interfaz de usuario
- [ ] Dashboard principal
- [ ] Visualización en tiempo real
- [ ] Gráficos históricos
- [ ] Alertas visuales

### Fase 4: Características avanzadas
- [ ] Códigos de error (DTC)
- [ ] Ingeniería inversa de PIDs propietarios
- [ ] Soporte multi-fabricante
- [ ] Exportación de datos

## 📦 Instalación

```bash
# Clonar el repositorio
git clone https://github.com/arturo393/cartracker.git
cd cartracker

# Abrir en Xcode
open Package.swift
```

## 🏃 Inicio Rápido

### Opción 1: Modo Demo (Sin Hardware)

Prueba la app sin necesidad de un dispositivo ELM327:

1. Instala Xcode desde App Store
2. Crea un proyecto iOS en Xcode
3. Importa los archivos Swift del proyecto
4. Ejecuta en simulador o dispositivo
5. Presiona "Modo Demo" para ver datos simulados

**📘 Guía completa**: [COMO_PROBAR.md](COMO_PROBAR.md)

### Opción 2: Con Dispositivo ELM327 Real

1. Conecta el ELM327 al puerto OBD-II del vehículo
2. Enciende el vehículo
3. Empareja el ELM327 con Bluetooth
4. Abre la app y selecciona el dispositivo
5. ¡Listo para monitorear!

## 🛠️ Comandos Útiles

```bash
# Ver todos los comandos disponibles
make help

# Ejecutar tests
make test

# Limpiar build
make clean

# Setup proyecto Xcode
./setup_xcode.sh

# Ver demo de funcionalidades
./demo.sh
```

## 🔧 Configuración del dispositivo ELM327

1. Conectar el dispositivo ELM327 al puerto OBD-II del vehículo
2. Encender el vehículo (o poner la llave en posición ACC)
3. Emparejar el dispositivo ELM327 con el iPhone vía Bluetooth
4. Abrir la app CarTracker y seleccionar el dispositivo

## 📖 Documentación de referencia

### Protocolo OBD-II
- [OBD-II PIDs](https://en.wikipedia.org/wiki/OBD-II_PIDs)
- [SAE J1979 Standard](https://www.sae.org/standards/content/j1979_201702/)

### ELM327
- [ELM327 Command Set](https://www.elmelectronics.com/wp-content/uploads/2016/07/ELM327DS.pdf)
- [AT Commands Reference](https://www.sparkfun.com/datasheets/Widgets/ELM327_AT_Commands.pdf)

### Proyectos similares de referencia

#### Swift/iOS
- **[SwiftOBD2](https://github.com/kkonteh97/SwiftOBD2)** ⭐ - Toolkit OBD2 versátil para desarrolladores Swift (actualizado recientemente)
- **[LTSupportAutomotive](https://github.com/mickeyl/LTSupportAutomotive)** - Librería iOS/watchOS/macOS para OBD2 (Objective-C)

#### Otras plataformas (referencia)
- [ELMduino](https://github.com/PowerBroker2/ELMduino) - Librería Arduino para ELM327 (C++)
- [python-OBD](https://github.com/brendan-w/python-OBD) - Librería Python para OBD-II
- [AndrOBD](https://github.com/fr3ts0n/AndrOBD) - App Android para diagnóstico OBD
- [ELM327-emulator](https://github.com/Ircama/ELM327-emulator) - Emulador ELM327 para testing

#### Recursos útiles
- [awesome-canbus](https://github.com/iDoka/awesome-canbus) - Lista curada de herramientas CAN bus
- [awesome-automotive-can-id](https://github.com/iDoka/awesome-automotive-can-id) - Colección de CAN IDs por fabricante
- Más proyectos: [GitHub OBD2 projects](https://github.com/topics/obd2) | [GitHub ELM327 projects](https://github.com/topics/elm327)

## 🤝 Contribuir

Las contribuciones son bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Issues y Proyecto

- **Issues**: [github.com/arturo393/cartracker/issues](https://github.com/arturo393/cartracker/issues)
- **Project Board**: [github.com/users/arturo393/projects/4](https://github.com/users/arturo393/projects/4)

## � Documentación Adicional

- **[Arquitectura](/.github/ARCHITECTURE.md)**: Documentación técnica detallada del proyecto
- **[Guía de Contribución](/.github/CONTRIBUTING.md)**: Cómo contribuir al proyecto
- **[Referencias](/.github/REFERENCES.md)**: Proyectos y recursos de referencia

## 🧪 Testing

El proyecto incluye una suite completa de tests unitarios:

```bash
# Ejecutar todos los tests
swift test

# Ejecutar con cobertura
swift test --enable-code-coverage

# Desde Xcode
Cmd+U
```

**Cobertura actual**: >80% en parsers OBD-II y lógica de negocio

## 🔄 CI/CD

GitHub Actions configurado para:
- ✅ Build automático en macOS
- ✅ Ejecución de tests
- ✅ SwiftLint (calidad de código)
- ✅ Markdown linting

## �📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 👤 Autor

**Arturo**
- GitHub: [@arturo393](https://github.com/arturo393)

## 🙏 Agradecimientos

- Comunidad de desarrolladores OBD-II
- Proyectos open source de ELM327
- Foros de ingeniería automotriz

---

⭐ Si este proyecto te resulta útil, considera darle una estrella!
