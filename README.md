# 🚗 CarTracker

Una aplicación iOS para leer y almacenar datos de vehículos en tiempo real utilizando el lector ELM327 conectado al puerto OBD-II mediante Bluetooth.

## 📋 Descripción

CarTracker permite monitorear los datos del vehículo en tiempo real, almacenarlos en una base de datos local y visualizarlos de manera intuitiva. El proyecto incluye soporte para ingeniería inversa de PIDs propietarios de diferentes fabricantes.

## ✨ Características

- 🔵 **Conexión Bluetooth**: Comunicación con dispositivos ELM327
- 📊 **Datos en tiempo real**: Lectura continua de parámetros del vehículo
- 💾 **Almacenamiento**: Base de datos local para histórico de datos
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
- [ ] Diseño de esquema de base de datos
- [ ] Implementación de capa de persistencia
- [ ] Histórico de datos

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
- [python-OBD](https://github.com/brendan-w/python-OBD) - Librería Python para OBD-II
- [OBDSim](https://github.com/Ircama/OBDSim) - Simulador de dispositivo OBD-II
- [torque-obd2-plugin](https://github.com/frankcaron/torque-obd2-plugin) - Plugin para Torque
- Buscar más en: [GitHub OBD-II projects](https://github.com/topics/obd2)

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

## 📄 Licencia

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
