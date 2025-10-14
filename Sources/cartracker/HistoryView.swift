import SwiftUI

// MARK: - History View

struct HistoryView: View {
    @State private var readings: [VehicleReading] = []
    @State private var trips: [Trip] = []
    @State private var selectedTrip: Trip?
    @State private var showingExportSheet = false
    @State private var showingStatistics = false
    @State private var searchText = ""
    @State private var selectedDateRange: DateRange = .today

    enum DateRange: String, CaseIterable {
        case today = "Hoy"
        case week = "Esta semana"
        case month = "Este mes"
        case all = "Todo"

        var dateRange: (start: Date, end: Date) {
            let calendar = Calendar.current
            let now = Date()

            switch self {
            case .today:
                let start = calendar.startOfDay(for: now)
                return (start, now)
            case .week:
                let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now
                return (start, now)
            case .month:
                let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return (start, now)
            case .all:
                let start = calendar.date(byAdding: .year, value: -1, to: now) ?? now
                return (start, now)
            }
        }
    }

    var filteredReadings: [VehicleReading] {
        var filtered = readings

        // Filtrar por rango de fechas
        let (startDate, endDate) = selectedDateRange.dateRange
        filtered = filtered.filter { reading in
            reading.timestamp >= startDate && reading.timestamp <= endDate
        }

        // Filtrar por viaje seleccionado
        if let trip = selectedTrip {
            filtered = filtered.filter { $0.trip == trip }
        }

        // Filtrar por búsqueda
        if !searchText.isEmpty {
            filtered = filtered.filter { reading in
                reading.formattedTimestamp.lowercased().contains(searchText.lowercased()) ||
                reading.rpmString.lowercased().contains(searchText.lowercased()) ||
                reading.speedString.lowercased().contains(searchText.lowercased())
            }
        }

        return filtered.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filtros
                VStack(spacing: 12) {
                    HStack {
                        Text("Histórico de Datos")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

                        Button(action: { showingStatistics = true }) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                        }

                        Button(action: { showingExportSheet = true }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.green)
                        }
                    }

                    // Selector de rango de fechas
                    Picker("Rango", selection: $selectedDateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Selector de viaje
                    if !trips.isEmpty {
                        Picker("Viaje", selection: $selectedTrip) {
                            Text("Todos los viajes").tag(Trip?.none)
                            ForEach(trips, id: \.self) { trip in
                                Text(trip.formattedDuration).tag(Trip?.some(trip))
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    // Barra de búsqueda
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Buscar lecturas...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding()
                .background(Color(.systemBackground))

                // Lista de lecturas
                if filteredReadings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text("No hay datos disponibles")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        Text("Conecta un dispositivo ELM327 y comienza a monitorear tu vehículo para ver el histórico aquí.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredReadings) { reading in
                        ReadingRowView(reading: reading)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingExportSheet) {
                ExportView()
            }
            .sheet(isPresented: $showingStatistics) {
                StatisticsView()
            }
            .onAppear {
                loadData()
            }
            .refreshable {
                loadData()
            }
        }
    }

    private func loadData() {
        readings = DataManager.shared.fetchReadings()
        trips = DataManager.shared.fetchTrips()
    }
}

// MARK: - Reading Row View

struct ReadingRowView: View {
    let reading: VehicleReading

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Timestamp y estado de conexión
            HStack {
                Text(reading.formattedTimestamp)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Circle()
                    .fill(reading.isConnected ? Color.green : Color.red)
                    .frame(width: 8, height: 8)

                Text(reading.isConnected ? "Conectado" : "Desconectado")
                    .font(.caption)
                    .foregroundColor(reading.isConnected ? .green : .red)
            }

            // Datos principales
            HStack(spacing: 16) {
                DataItemView(label: "RPM", value: reading.rpmString, color: .red)
                DataItemView(label: "Velocidad", value: reading.speedString, color: .blue)
                DataItemView(label: "Temp", value: reading.tempString, color: .orange)
                DataItemView(label: "Combustible", value: reading.fuelString, color: .green)
            }

            // Datos secundarios
            HStack(spacing: 16) {
                DataItemView(label: "Acelerador", value: String(format: "%.1f%%", reading.throttlePosition), color: .purple)
                DataItemView(label: "Carga", value: String(format: "%.1f%%", reading.engineLoad), color: .cyan)
                DataItemView(label: "MAF", value: String(format: "%.1f g/s", reading.maf), color: .indigo)
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Data Item View

struct DataItemView: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Export View

struct ExportView: View {
    @State private var csvContent: String?
    @State private var showingShareSheet = false

    var body: some View {
        NavigationStack {
            VStack {
                if let csv = csvContent {
                    Text("Datos exportados exitosamente")
                        .font(.headline)
                        .padding()

                    Text("\(csv.components(separatedBy: "\n").count - 1) lecturas exportadas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: { showingShareSheet = true }) {
                        Label("Compartir CSV", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding()
                } else {
                    ProgressView("Generando archivo CSV...")
                        .padding()
                }
            }
            .navigationTitle("Exportar Datos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        // Dismiss sheet
                    }
                }
            }
            .onAppear {
                csvContent = DataManager.shared.exportToCSV()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let csv = csvContent {
                    ShareSheet(items: [csv])
                }
            }
        }
    }
}

// MARK: - Statistics View

struct StatisticsView: View {
    @State private var statistics: VehicleStatistics = .empty

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Estadísticas generales
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Estadísticas Generales")
                            .font(.title2)
                            .fontWeight(.bold)

                        StatCardView(title: "Total de Lecturas", value: statistics.formattedTotalReadings, icon: "chart.bar.fill")
                        StatCardView(title: "Total de Viajes", value: statistics.formattedTotalTrips, icon: "car.fill")
                        StatCardView(title: "Rango de Fechas", value: statistics.formattedDateRange, icon: "calendar")
                    }

                    // Estadísticas de RPM
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Motor (RPM)")
                            .font(.title2)
                            .fontWeight(.bold)

                        StatCardView(title: "RPM Promedio", value: statistics.formattedAverageRPM, icon: "speedometer")
                        StatCardView(title: "RPM Máximo", value: statistics.formattedMaxRPM, icon: "gauge.high")
                    }

                    // Estadísticas de velocidad
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Velocidad")
                            .font(.title2)
                            .fontWeight(.bold)

                        StatCardView(title: "Velocidad Promedio", value: statistics.formattedAverageSpeed, icon: "speedometer")
                        StatCardView(title: "Velocidad Máxima", value: statistics.formattedMaxSpeed, icon: "gauge.high")
                    }

                    // Estadísticas de temperatura
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Temperatura del Motor")
                            .font(.title2)
                            .fontWeight(.bold)

                        StatCardView(title: "Temperatura Promedio", value: statistics.formattedAverageTemp, icon: "thermometer.medium")
                        StatCardView(title: "Temperatura Máxima", value: statistics.formattedMaxTemp, icon: "thermometer.high")
                    }

                    // Estadísticas de combustible
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Combustible")
                            .font(.title2)
                            .fontWeight(.bold)

                        StatCardView(title: "Nivel Promedio", value: statistics.formattedAverageFuelLevel, icon: "fuelpump.fill")
                    }
                }
                .padding()
            }
            .navigationTitle("Estadísticas")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                statistics = DataManager.shared.getStatistics()
            }
        }
    }
}

// MARK: - Stat Card View

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}