# Makefile para CarTracker
# Comandos útiles para desarrollo

.PHONY: help build test clean run-tests lint setup-xcode demo

# Variables
SWIFT_BUILD_FLAGS = -Xswiftc -suppress-warnings
SWIFT_TEST_FLAGS = --enable-code-coverage

help: ## Muestra esta ayuda
	@echo "CarTracker - Comandos Disponibles:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

build: ## Compila el proyecto (solo biblioteca, no app completa)
	@echo "🔨 Compilando CarTracker..."
	swift build $(SWIFT_BUILD_FLAGS)
	@echo "✅ Compilación exitosa"

test: ## Ejecuta los tests unitarios
	@echo "🧪 Ejecutando tests..."
	swift test $(SWIFT_TEST_FLAGS)
	@echo "✅ Tests completados"

test-verbose: ## Ejecuta tests con output detallado
	@echo "🧪 Ejecutando tests (modo verbose)..."
	swift test --verbose

clean: ## Limpia archivos de build
	@echo "🗑️  Limpiando archivos de build..."
	swift package clean
	rm -rf .build
	@echo "✅ Limpieza completada"

reset: clean ## Limpia y resetea el paquete completo
	@echo "🔄 Reseteando paquete..."
	swift package reset
	@echo "✅ Reset completado"

lint: ## Verifica el código (requiere SwiftLint instalado)
	@if command -v swiftlint >/dev/null 2>&1; then \
		echo "🔍 Ejecutando SwiftLint..."; \
		swiftlint; \
	else \
		echo "⚠️  SwiftLint no está instalado"; \
		echo "Instalar con: brew install swiftlint"; \
	fi

setup-xcode: ## Genera estructura para proyecto Xcode
	@echo "🚀 Configurando proyecto Xcode..."
	./setup_xcode.sh
	@echo "✅ Setup completado"

xcode-project: ## Genera archivo .xcodeproj (framework, no app)
	@echo "📦 Generando proyecto Xcode..."
	swift package generate-xcodeproj
	@echo "⚠️  Nota: Esto genera un framework, no una app iOS"
	@echo "Para app completa, usa: make setup-xcode"

demo: ## Información sobre modo demo
	@echo "🎭 Modo Demo"
	@echo ""
	@echo "El proyecto incluye un modo demo que simula datos del vehículo"
	@echo "sin necesidad de hardware ELM327."
	@echo ""
	@echo "Para usarlo:"
	@echo "1. Ejecuta la app en simulador o dispositivo"
	@echo "2. Presiona el botón 'Modo Demo'"
	@echo "3. La app mostrará datos simulados realistas"
	@echo ""

info: ## Muestra información del proyecto
	@echo "📊 Información del Proyecto CarTracker"
	@echo ""
	@echo "Plataformas soportadas:"
	@swift package describe | grep -A 5 "Platforms:"
	@echo ""
	@echo "Targets:"
	@swift package describe | grep -A 10 "Targets:"
	@echo ""

coverage: test ## Genera reporte de cobertura de tests
	@echo "📈 Generando reporte de cobertura..."
	@xcrun llvm-cov report \
		.build/debug/cartrackerPackageTests.xctest/Contents/MacOS/cartrackerPackageTests \
		-instr-profile .build/debug/codecov/default.profdata \
		-ignore-filename-regex=".build|Tests" \
		-use-color
	@echo ""
	@echo "Para reporte HTML, usa: make coverage-html"

coverage-html: test ## Genera reporte HTML de cobertura
	@echo "📊 Generando reporte HTML de cobertura..."
	@mkdir -p coverage
	@xcrun llvm-cov show \
		.build/debug/cartrackerPackageTests.xctest/Contents/MacOS/cartrackerPackageTests \
		-instr-profile .build/debug/codecov/default.profdata \
		-ignore-filename-regex=".build|Tests" \
		-format=html > coverage/index.html
	@echo "✅ Reporte generado en: coverage/index.html"
	@open coverage/index.html

install-swiftlint: ## Instala SwiftLint (requiere Homebrew)
	@echo "📦 Instalando SwiftLint..."
	brew install swiftlint
	@echo "✅ SwiftLint instalado"

check: ## Verifica que todo esté correcto antes de commit
	@echo "🔍 Verificando proyecto..."
	@make lint || true
	@make test
	@echo "✅ Verificación completada"

# Comandos para desarrollo en Xcode
xcode-build: ## Compila con xcodebuild (requiere .xcodeproj)
	@if [ -f "CarTracker.xcodeproj/project.pbxproj" ]; then \
		echo "🔨 Compilando con xcodebuild..."; \
		xcodebuild -scheme cartracker build; \
	else \
		echo "❌ No se encontró CarTracker.xcodeproj"; \
		echo "Ejecuta: make setup-xcode primero"; \
	fi

xcode-test: ## Ejecuta tests con xcodebuild
	@if [ -f "CarTracker.xcodeproj/project.pbxproj" ]; then \
		echo "🧪 Ejecutando tests con xcodebuild..."; \
		xcodebuild -scheme cartracker test; \
	else \
		echo "❌ No se encontró CarTracker.xcodeproj"; \
	fi

# Información útil
requirements: ## Muestra los requisitos del sistema
	@echo "📋 Requisitos del Sistema:"
	@echo ""
	@echo "✓ Swift 5.9 o superior"
	@swift --version
	@echo ""
	@echo "✓ Xcode 15.0 o superior"
	@xcodebuild -version
	@echo ""
	@echo "✓ iOS 17.0+ o macOS 14.0+"
	@echo ""

docs: ## Abre la documentación
	@echo "📚 Abriendo documentación..."
	@open README.md
	@open .github/ARCHITECTURE.md
	@open .github/BUILD_GUIDE.md

github: ## Abre el repositorio en GitHub
	@echo "🌐 Abriendo repositorio..."
	@open https://github.com/arturo393/cartracker

.DEFAULT_GOAL := help
