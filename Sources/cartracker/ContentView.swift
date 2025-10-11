import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    @State private var bluetoothManager = BluetoothManager()
    @State private var showDeviceList = false
    @State private var showDTCList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo degradado
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header de conexión
                        ConnectionHeaderView(
                            isConnected: bluetoothManager.isConnected,
                            status: bluetoothManager.connectionStatus,
                            onConnectTap: { showDeviceList = true },
                            onDisconnectTap: { bluetoothManager.disconnect() }
                        )
                        
                        if bluetoothManager.isConnected {
                            // Datos principales
                            MainDataView(vehicleData: bluetoothManager.vehicleData)
                            
                            // Datos secundarios
                            SecondaryDataView(vehicleData: bluetoothManager.vehicleData)
                            
                            // Botón de códigos de error
                            Button(action: { showDTCList = true }) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("Ver Códigos de Error")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(12)
                            }
                        } else {
                            // Vista de estado desconectado
                            DisconnectedView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("CarTracker")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showDeviceList) {
                DeviceListView(bluetoothManager: bluetoothManager)
            }
            .sheet(isPresented: $showDTCList) {
                DTCListView(bluetoothManager: bluetoothManager)
            }
        }
    }
}

// MARK: - Connection Header View

struct ConnectionHeaderView: View {
    let isConnected: Bool
    let status: String
    let onConnectTap: () -> Void
    let onDisconnectTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Estado de Conexión")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Circle()
                        .fill(isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    
                    Text(status)
                        .font(.headline)
                }
            }
            
            Spacer()
            
            Button(action: isConnected ? onDisconnectTap : onConnectTap) {
                Text(isConnected ? "Desconectar" : "Conectar")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(isConnected ? Color.red : Color.blue)
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Main Data View

struct MainDataView: View {
    let vehicleData: VehicleData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // RPM Gauge
                GaugeCardView(
                    title: "RPM",
                    value: vehicleData.rpm,
                    maxValue: 8000,
                    unit: "",
                    color: .red,
                    icon: "speedometer"
                )
                
                // Speed Gauge
                GaugeCardView(
                    title: "Velocidad",
                    value: vehicleData.speed,
                    maxValue: 200,
                    unit: "km/h",
                    color: .blue,
                    icon: "gauge.high"
                )
            }
            
            // Temperature
            DataCardView(
                title: "Temperatura Motor",
                value: "\(vehicleData.engineTemp)°C",
                icon: "thermometer",
                color: temperatureColor(vehicleData.engineTemp)
            )
        }
    }
    
    private func temperatureColor(_ temp: Int) -> Color {
        switch temp {
        case ..<70: return .blue
        case 70..<95: return .green
        case 95..<105: return .orange
        default: return .red
        }
    }
}

// MARK: - Secondary Data View

struct SecondaryDataView: View {
    let vehicleData: VehicleData
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                SmallDataCard(
                    title: "Combustible",
                    value: String(format: "%.1f%%", vehicleData.fuelLevel),
                    icon: "fuelpump.fill",
                    color: .orange
                )
                
                SmallDataCard(
                    title: "Acelerador",
                    value: String(format: "%.1f%%", vehicleData.throttlePosition),
                    icon: "pedal.accelerator",
                    color: .green
                )
            }
            
            HStack(spacing: 12) {
                SmallDataCard(
                    title: "Carga Motor",
                    value: String(format: "%.1f%%", vehicleData.engineLoad),
                    icon: "engine.combustion.fill",
                    color: .purple
                )
                
                SmallDataCard(
                    title: "MAF",
                    value: String(format: "%.2f g/s", vehicleData.maf),
                    icon: "wind",
                    color: .cyan
                )
            }
        }
    }
}

// MARK: - Gauge Card View

struct GaugeCardView: View {
    let title: String
    let value: Int
    let maxValue: Int
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(value)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color)
            
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            ProgressView(value: Double(value), total: Double(maxValue))
                .tint(color)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Data Card View

struct DataCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Small Data Card

struct SmallDataCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Disconnected View

struct DisconnectedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("No Conectado")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Conecta tu dispositivo ELM327 para comenzar a monitorear los datos de tu vehículo")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                InstructionRow(number: 1, text: "Conecta el ELM327 al puerto OBD-II del vehículo")
                InstructionRow(number: 2, text: "Enciende el vehículo")
                InstructionRow(number: 3, text: "Presiona 'Conectar' y selecciona tu dispositivo")
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
    }
}

struct InstructionRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Device List View

struct DeviceListView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var bluetoothManager: BluetoothManager
    
    var body: some View {
        NavigationStack {
            List {
                if bluetoothManager.discoveredDevices.isEmpty {
                    VStack(spacing: 16) {
                        if bluetoothManager.isScanning {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Buscando dispositivos...")
                                .foregroundColor(.secondary)
                        } else {
                            Text("No se encontraron dispositivos")
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                        Button(action: {
                            bluetoothManager.connect(to: device)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text(device.name ?? "Dispositivo Desconocido")
                                        .font(.headline)
                                    Text(device.identifier.uuidString)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dispositivos Bluetooth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        bluetoothManager.stopScanning()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(bluetoothManager.isScanning ? "Detener" : "Buscar") {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    }
                }
            }
            .onAppear {
                bluetoothManager.startScanning()
            }
            .onDisappear {
                bluetoothManager.stopScanning()
            }
        }
    }
}

// MARK: - DTC List View

struct DTCListView: View {
    @Environment(\.dismiss) var dismiss
    let bluetoothManager: BluetoothManager
    @State private var dtcCodes: [DTCCode] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Text("Leyendo códigos...")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else if dtcCodes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("No hay códigos de error")
                            .font(.headline)
                        Text("Tu vehículo no tiene códigos de diagnóstico activos")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(dtcCodes) { code in
                        DTCRowView(code: code)
                    }
                }
            }
            .navigationTitle("Códigos de Error")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: loadDTCs) {
                            Label("Recargar", systemImage: "arrow.clockwise")
                        }
                        
                        Button(role: .destructive, action: clearDTCs) {
                            Label("Borrar Códigos", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .onAppear {
                loadDTCs()
            }
        }
    }
    
    private func loadDTCs() {
        isLoading = true
        bluetoothManager.readDTCs { codes in
            dtcCodes = codes
            isLoading = false
        }
    }
    
    private func clearDTCs() {
        bluetoothManager.clearDTCs { success in
            if success {
                dtcCodes = []
            }
        }
    }
}

struct DTCRowView: View {
    let code: DTCCode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(code.code)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(code.severity.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(severityColor.opacity(0.2))
                    .foregroundColor(severityColor)
                    .cornerRadius(8)
            }
            
            Text(code.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(code.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var severityColor: Color {
        switch code.severity {
        case .critical: return .red
        case .major: return .orange
        case .minor: return .yellow
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
