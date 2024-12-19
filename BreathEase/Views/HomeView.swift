import SwiftUI

struct HomeView: View {
    @State private var isAnalyzing = false
    @State private var breathingScore: Double = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.meshGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Daily stats card with glassmorphism
                        VStack(spacing: 15) {
                            HStack {
                                Text("Today's Breathing")
                                    .font(.title2)
                                    .bold()
                                Spacer()
                                Circle()
                                    .fill(breathingScore > 80 ? Theme.success : Theme.warning)
                                    .frame(width: 12, height: 12)
                            }
                            
                            // Waveform visualization
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 180)
                                
                                if isAnalyzing {
                                    WaveformView()
                                        .transition(.scale.combined(with: .opacity))
                                } else {
                                    Text("Start breathing analysis")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10)
                        )
                        .padding(.horizontal)
                        
                        // Main action button with breathing animation
                        ZStack {
                            Circle()
                                .fill(Theme.gradient)
                                .frame(width: isAnalyzing ? 150 : 120, height: isAnalyzing ? 150 : 120)
                                .scaleEffect(isAnalyzing ? 1.1 : 1.0)
                                .animation(Theme.breathingAnimation.repeatForever(autoreverses: true), value: isAnalyzing)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isAnalyzing.toggle()
                                }
                            }) {
                                Circle()
                                    .fill(
                                        isAnalyzing ? 
                                            Theme.error.gradient : 
                                            Theme.gradient
                                    )
                                    .frame(width: 120, height: 120)
                                    .overlay {
                                        VStack(spacing: 8) {
                                            Image(systemName: isAnalyzing ? "stop.fill" : "mic.fill")
                                                .font(.system(size: 40))
                                                .symbolEffect(.bounce, value: isAnalyzing)
                                            Text(isAnalyzing ? "Stop" : "Start")
                                                .font(.headline)
                                        }
                                        .foregroundStyle(.white)
                                    }
                                    .shadow(color: .black.opacity(0.2), radius: 10)
                            }
                        }
                        
                        // Quick stats with animated appearance
                        if isAnalyzing {
                            HStack(spacing: 20) {
                                ForEach(["Rate", "Depth", "Quality"], id: \.self) { stat in
                                    StatCard(
                                        title: stat,
                                        value: "\(Int.random(in: 70...100))",
                                        unit: stat == "Rate" ? "bpm" : "%"
                                    )
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("BreathEase")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "bell.badge")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Theme.gradient)
                                .symbolEffect(.bounce, options: .repeat(2))
                        }
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .bold()
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
    }
}

struct WaveformView: View {
    @State private var phase = 0.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let width = size.width
                let height = size.height
                let centerY = height / 2
                
                var path = Path()
                path.move(to: CGPoint(x: 0, y: centerY))
                
                for x in 0...Int(width) {
                    let relativeX = Double(x) / 50
                    let sine = sin(relativeX + phase)
                    let y = centerY + sine * 30
                    path.addLine(to: CGPoint(x: Double(x), y: y))
                }
                
                context.stroke(path, with: .color(.blue), lineWidth: 3)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
} 