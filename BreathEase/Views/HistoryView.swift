import SwiftUI
import Charts

struct HistoryView: View {
    @State private var selectedTimeRange = TimeRange.week
    @State private var animate = false
    let breathingData = BreathingRecord.sampleData
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.meshGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Time range picker with custom style
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal)
                        
                        // Breathing score chart with animation
                        ChartCard(title: "Breathing Score", data: breathingData)
                            .scaleEffect(animate ? 1 : 0.9)
                            .opacity(animate ? 1 : 0)
                        
                        // Daily records with staggered animation
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Daily Records")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            ForEach(Array(breathingData.prefix(7).enumerated()), id: \.element.id) { index, record in
                                DailyRecordRow(record: record)
                                    .transition(.slide)
                                    .offset(x: animate ? 0 : -100)
                                    .opacity(animate ? 1 : 0)
                                    .animation(.easeOut.delay(Double(index) * 0.1), value: animate)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("History")
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

struct ChartCard: View {
    let title: String
    let data: [BreathingRecord]
    @State private var selectedPoint: BreathingRecord?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.title2)
                .bold()
            
            Chart(data) { record in
                LineMark(
                    x: .value("Date", record.date),
                    y: .value("Score", record.score)
                )
                .foregroundStyle(Theme.gradient)
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", record.date),
                    y: .value("Score", record.score)
                )
                .foregroundStyle(Theme.gradient.opacity(0.1))
                .interpolationMethod(.catmullRom)
                
                if let selectedPoint = selectedPoint, selectedPoint.id == record.id {
                    PointMark(
                        x: .value("Date", record.date),
                        y: .value("Score", record.score)
                    )
                    .foregroundStyle(Theme.gradient)
                    .symbolSize(100)
                }
            }
            .frame(height: 200)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let x = value.location.x - geometry.frame(in: .local).origin.x
                                    if let date = proxy.value(atX: x) as Date? {
                                        selectedPoint = data.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
                                    }
                                }
                                .onEnded { _ in
                                    selectedPoint = nil
                                }
                        )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.1), radius: 10)
        .padding(.horizontal)
    }
}

struct DailyRecordRow: View {
    let record: BreathingRecord
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Text("\(record.exercises) exercises completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(Int(record.score))")
                .font(.title2)
                .bold()
                .foregroundStyle(
                    record.score > 80 ? Theme.success.gradient : Theme.warning.gradient
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
        .padding(.horizontal)
        .scaleEffect(isHovered ? 1.02 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct BreathingRecord: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double
    let exercises: Int
    
    static let sampleData: [BreathingRecord] = {
        let calendar = Calendar.current
        return (0..<14).map { days in
            BreathingRecord(
                date: calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date(),
                score: Double.random(in: 70...100),
                exercises: Int.random(in: 1...5)
            )
        }
    }()
}

enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var id: String { self.rawValue }
} 