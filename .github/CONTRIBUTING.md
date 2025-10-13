# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir a CarTracker! Este documento proporciona guías y mejores prácticas para contribuir al proyecto.

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [Cómo Empezar](#cómo-empezar)
- [Proceso de Desarrollo](#proceso-de-desarrollo)
- [Estándares de Código](#estándares-de-código)
- [Testing](#testing)
- [Commit Messages](#commit-messages)
- [Pull Requests](#pull-requests)

## Código de Conducta

Este proyecto adopta un código de conducta que esperamos que todos los participantes cumplan. Por favor, lee [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) antes de contribuir.

## Cómo Empezar

### Requisitos Previos

- Xcode 15.0 o superior
- Swift 5.9 o superior
- macOS 14.0 o superior
- Conocimientos de SwiftUI y Core Bluetooth
- Dispositivo iOS físico (para testing con Bluetooth)

### Configuración del Entorno

1. **Fork el repositorio**
   ```bash
   # Clic en "Fork" en GitHub
   ```

2. **Clonar tu fork**
   ```bash
   git clone https://github.com/TU_USUARIO/cartracker.git
   cd cartracker
   ```

3. **Agregar upstream remote**
   ```bash
   git remote add upstream https://github.com/arturo393/cartracker.git
   ```

4. **Abrir en Xcode**
   ```bash
   open Package.swift
   ```

5. **Ejecutar tests**
   ```bash
   swift test
   # O desde Xcode: Cmd+U
   ```

## Proceso de Desarrollo

### 1. Elige un Issue

- Busca issues con label `good first issue` para comenzar
- Comenta en el issue que estás trabajando en él
- Si no hay issue para tu idea, crea uno primero

### 2. Crea una Rama

```bash
git checkout -b feature/nombre-descriptivo
# o
git checkout -b fix/nombre-del-bug
```

**Convenciones de nombres de ramas:**
- `feature/`: Nueva funcionalidad
- `fix/`: Corrección de bugs
- `docs/`: Cambios en documentación
- `test/`: Agregar o modificar tests
- `refactor/`: Refactorización sin cambiar funcionalidad

### 3. Desarrolla

- Escribe código limpio y bien documentado
- Sigue los [Estándares de Código](#estándares-de-código)
- Agrega tests para nueva funcionalidad
- Actualiza documentación si es necesario

### 4. Commits

```bash
git add .
git commit -m "feat: descripción clara del cambio"
```

Ver [Commit Messages](#commit-messages) para convenciones.

### 5. Mantén tu Rama Actualizada

```bash
git fetch upstream
git rebase upstream/master
```

### 6. Push y Pull Request

```bash
git push origin tu-rama
```

Luego crea un Pull Request en GitHub.

## Estándares de Código

### Swift Style Guide

Seguimos las guías de estilo de Swift de Apple y algunas convenciones adicionales:

#### Naming

```swift
// ✅ Bueno
class VehicleDataManager { }
func calculateAverageSpeed() -> Double { }
var isConnected: Bool

// ❌ Malo
class vdm { }
func calcAvgSpd() -> Double { }
var connected: Bool
```

#### Organización de Archivos

```swift
// MARK: - Properties
private var someProperty: String

// MARK: - Initialization
init() { }

// MARK: - Public Methods
func publicMethod() { }

// MARK: - Private Methods
private func privateMethod() { }

// MARK: - Delegate Methods
extension MyClass: SomeDelegate {
    func delegateMethod() { }
}
```

#### SwiftUI Views

```swift
struct MyView: View {
    // MARK: - Properties
    @State private var someState: Bool = false
    let data: SomeData
    
    // MARK: - Body
    var body: some View {
        content
    }
    
    // MARK: - Subviews
    private var content: some View {
        VStack {
            // ...
        }
    }
    
    // MARK: - Methods
    private func performAction() {
        // ...
    }
}
```

#### Comentarios

```swift
/// Parsea la respuesta RPM del dispositivo OBD-II
/// 
/// - Parameter response: String hexadecimal de la respuesta
/// - Returns: RPM del motor o nil si la respuesta es inválida
static func parseRPM(_ response: String) -> Int? {
    // Implementación...
}
```

### Code Formatting

- **Indentación**: 4 espacios (no tabs)
- **Línea máxima**: 120 caracteres
- **Llaves**: Estilo Allman modificado
```swift
func myFunction() {
    if condition {
        // código
    }
}
```

### Imports

```swift
// Primero Foundation/UIKit/SwiftUI
import Foundation
import SwiftUI
import CoreBluetooth

// Luego dependencias de terceros
// import SomeDependency

// Finalmente módulos internos
@testable import cartracker
```

## Testing

### Unit Tests

Todos los nuevos parsers y lógica de negocio deben tener tests:

```swift
func testParseRPM_ValidResponse() {
    // Given
    let response = "41 0C 1F 40"
    
    // When
    let result = OBDResponseParser.parseRPM(response)
    
    // Then
    XCTAssertEqual(result, 2000)
}
```

### Coverage

- Mantener cobertura >80% para lógica crítica
- Los parsers OBD-II deben tener 100% coverage

### Ejecutar Tests

```bash
# Todos los tests
swift test

# Test específico
swift test --filter OBDResponseParserTests

# Desde Xcode
Cmd+U
```

## Commit Messages

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

### Formato

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formateo, semicolons, etc (no cambia código)
- `refactor`: Refactorización (no agrega features ni arregla bugs)
- `test`: Agregar o modificar tests
- `chore`: Cambios en build, dependencias, etc

### Ejemplos

```bash
feat(bluetooth): add auto-reconnection support

fix(parser): correct MAF calculation formula

docs(readme): update installation instructions

test(obd): add tests for temperature parser
```

## Pull Requests

### Antes de Enviar

- [ ] Los tests pasan localmente
- [ ] El código sigue los estándares de estilo
- [ ] Has agregado tests para nuevo código
- [ ] Has actualizado la documentación
- [ ] Tu rama está actualizada con master
- [ ] Has resuelto todos los conflictos

### Template de PR

```markdown
## Descripción
Descripción clara de los cambios

## Tipo de Cambio
- [ ] Bug fix
- [ ] Nueva funcionalidad
- [ ] Breaking change
- [ ] Documentación

## Cómo Probar
Pasos para probar los cambios

## Screenshots (si aplica)
Agrega capturas de pantalla

## Checklist
- [ ] Tests agregados/actualizados
- [ ] Documentación actualizada
- [ ] Sin warnings de compilación
```

### Proceso de Revisión

1. Crea el PR
2. Espera revisión automática (CI)
3. Responde a comentarios de revisores
4. Haz cambios solicitados
5. PR es aprobado y merged

## Áreas de Contribución

### 🟢 Fácil (Good First Issue)

- Agregar tests para parsers existentes
- Mejorar documentación
- Agregar más códigos DTC conocidos
- Mejorar mensajes de error

### 🟡 Intermedio

- Implementar nuevos PIDs OBD-II
- Mejorar UI/UX
- Optimizar rendimiento Bluetooth
- Agregar persistencia de datos

### 🔴 Avanzado

- Implementar PIDs propietarios
- Sistema de plugins para fabricantes
- Modo offline con emulador
- Sincronización en la nube

## Recursos Útiles

### Documentación

- [Apple Developer - Core Bluetooth](https://developer.apple.com/documentation/corebluetooth)
- [Apple Developer - SwiftUI](https://developer.apple.com/documentation/swiftui)
- [OBD-II PIDs](https://en.wikipedia.org/wiki/OBD-II_PIDs)
- [ELM327 Commands](https://www.elmelectronics.com/wp-content/uploads/2016/07/ELM327DS.pdf)

### Proyectos de Referencia

- [SwiftOBD2](https://github.com/kkonteh97/SwiftOBD2)
- [LTSupportAutomotive](https://github.com/mickeyl/LTSupportAutomotive)

## Preguntas

Si tienes preguntas:
1. Revisa la [documentación](README.md)
2. Busca en [issues cerrados](https://github.com/arturo393/cartracker/issues?q=is%3Aissue+is%3Aclosed)
3. Abre un [nuevo issue](https://github.com/arturo393/cartracker/issues/new)
4. Únete a las [Discussions](https://github.com/arturo393/cartracker/discussions)

## Reconocimientos

Todos los contribuidores serán mencionados en [CONTRIBUTORS.md](CONTRIBUTORS.md).

---

¡Gracias por contribuir a CarTracker! 🚗💨
