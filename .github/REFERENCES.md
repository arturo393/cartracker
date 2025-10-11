# 📚 Referencias y Proyectos de Inspiración

Este documento lista los proyectos y recursos que estamos usando como referencia para desarrollar CarTracker.

## 🎯 Proyecto Principal de Referencia

### SwiftOBD2
- **URL**: https://github.com/kkonteh97/SwiftOBD2
- **Descripción**: Toolkit OBD2 versátil para desarrolladores Swift
- **Lenguaje**: Swift
- **Última actualización**: Muy reciente (10 horas ago al 11/10/2025)
- **Por qué lo usamos**: 
  - Implementación moderna en Swift
  - Soporte para ELM327
  - Incluye emulador para prototipado
  - Activamente mantenido

## 📱 Otros Proyectos iOS/macOS

### LTSupportAutomotive
- **URL**: https://github.com/mickeyl/LTSupportAutomotive
- **Descripción**: Librería iOS/watchOS/macOS para OBD2, VIN-Decoding
- **Lenguaje**: Objective-C
- **Plataformas**: iOS, watchOS, macOS
- **Características**: WiFi, Bluetooth, USB serial adapters

## 🔧 Proyectos de Referencia (Otras Plataformas)

### ELMduino (Arduino/C++)
- **URL**: https://github.com/PowerBroker2/ELMduino
- **Uso**: Entender la comunicación con ELM327 a bajo nivel
- **Útil para**: Protocolos AT commands

### python-OBD (Python)
- **URL**: https://github.com/brendan-w/python-OBD
- **Uso**: Referencia para parseo de PIDs estándar

### AndrOBD (Android/Java)
- **URL**: https://github.com/fr3ts0n/AndrOBD
- **Uso**: Ideas de UI/UX y features avanzadas
- **Características**: MQTT, charts, GPS, dashboard

### ELM327-emulator (Python)
- **URL**: https://github.com/Ircama/ELM327-emulator
- **Uso**: Testing sin hardware físico
- **Características**: Multi-ECU simulation

## 📖 Recursos de Documentación

### Protocolos OBD-II
- [Wikipedia OBD-II PIDs](https://en.wikipedia.org/wiki/OBD-II_PIDs)
- [SAE J1979 Standard](https://www.sae.org/standards/content/j1979_201702/)
- [ISO 15765-4 (CAN)](https://www.iso.org/standard/66378.html)

### ELM327
- [ELM327 Datasheet](https://www.elmelectronics.com/wp-content/uploads/2016/07/ELM327DS.pdf)
- [AT Commands Reference](https://www.sparkfun.com/datasheets/Widgets/ELM327_AT_Commands.pdf)

### Listas Curadas
- [awesome-canbus](https://github.com/iDoka/awesome-canbus) - Herramientas CAN bus
- [awesome-automotive-can-id](https://github.com/iDoka/awesome-automotive-can-id) - CAN IDs por fabricante

## 🔍 Ingeniería Inversa

### Proyectos de PIDs Propietarios
- [ArduinoHondaOBD](https://github.com/kerpz/ArduinoHondaOBD) - PIDs específicos de Honda
- [MQB-sniffer](https://github.com/mrfixpl/MQB-sniffer) - VW Golf MK7 (plataforma MQB)

### Herramientas de Diagnóstico
- [ddt4all](https://github.com/cedricp/ddt4all) - Herramienta OBD avanzada (Python)
- [python-udsoncan](https://github.com/pylessard/python-udsoncan) - UDS (ISO-14229)

## 🛠️ Herramientas de Desarrollo

### Testing y Simulación
- [OBD2_K-line_Reader](https://github.com/muki01/OBD2_K-line_Reader) - ISO9141 y ISO14230
- [esp32-obd2-emulator](https://github.com/limiter121/esp32-obd2-emulator) - Emulador con ESP32

### Implementaciones de Referencia
- [kotlin-obd-api](https://github.com/eltonvs/kotlin-obd-api) - API Kotlin para OBD-II
- [elmobd](https://github.com/rzetterberg/elmobd) - Librería Go para OBD-II
- [OBD.NET](https://github.com/DarthAffe/OBD.NET) - Librería C# para ELM327/STN1170

## 📊 Proyectos de Visualización
- [ESP32-OBD2-Gauge](https://github.com/VaAndCob/ESP32-OBD2-Gauge) - Gauge con ESP32 y TFT
- [aa-torque](https://github.com/agronick/aa-torque) - Monitor de performance para Android Auto

## 🔒 Seguridad Automotriz
- [CarHackingTools](https://github.com/jgamblin/CarHackingTools) - Herramientas de car hacking
- [PcmHacks](https://github.com/LegacyNsfw/PcmHacks) - Reflash de ECU

## 📝 Notas de Implementación

### Prioridad 1: Comunicación Bluetooth
- Usar Core Bluetooth framework de iOS
- Implementar patrón de comandos AT basado en SwiftOBD2
- Manejar respuestas asíncronas

### Prioridad 2: Parseo de PIDs
- Empezar con PIDs estándar (Mode 01)
- Implementar conversiones según fórmulas OBD-II
- Validar contra especificación SAE J1979

### Prioridad 3: Almacenamiento
- Evaluar Core Data vs SQLite vs Realm
- Diseñar esquema normalizado para series temporales
- Considerar sincronización en la nube

### Prioridad 4: PIDs Propietarios
- Documentar hallazgos en repositorio separado
- Crear base de datos de PIDs por fabricante
- Implementar detección automática de vehículo

---

**Última actualización**: 11 de octubre de 2025
