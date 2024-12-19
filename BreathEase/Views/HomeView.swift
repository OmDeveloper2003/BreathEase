import SwiftUI

struct HomeView: View {
    @State private var isAnalyzing = false
    @State private var breathingScore: Double = 0
    @State private var showPulseRings = false
    @State private var ringProgress: CGFloat = 0
    
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
                                
                                // Animated score indicator
                                ScoreIndicator(score: breathingScore)
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
                                    VStack(spacing: 10) {
                                        Image(systemName: "waveform")
                                            .font(.system(size: 40))
                                            .foregroundStyle(Theme.gradient)
                                            .floating()
                                        Text("Start breathing analysis")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .padding()
                        .glassMorphic()
                        .padding(.horizontal)
                        
                        // Breathing rings animation
                        ZStack {
                            // Outer pulse rings
                            if showPulseRings {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .stroke(Theme.gradient, lineWidth: 1)
                                        .scaleEffect(showPulseRings ? 2 : 1)
                                        .opacity(showPulseRings ? 0 : 0.5)
                                        .animation(
                                            .easeOut(duration: 2)
                                            .repeatForever(autoreverses: false)
                                            .delay(Double(index) * 0.5),
                                            value: showPulseRings
                                        )
                                }
                            }
                            
                            // Progress ring
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                                .frame(width: 140, height: 140)
                            
                            Circle()
                                .trim(from: 0, to: ringProgress)
                                .stroke(Theme.gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 140, height: 140)
                                .rotationEffect(.degrees(-90))
                            
                            // Main action button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isAnalyzing.toggle()
                                    showPulseRings = isAnalyzing
                                    
                                    if isAnalyzing {
                                        withAnimation(.linear(duration: 2)) {
                                            ringProgress = 1
                                        }
                                    } else {
                                        ringProgress = 0
                                    }
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
                            }
                        }
                        
                        // Quick stats with animated appearance
                        if isAnalyzing {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 20) {
                                StatCard(
                                    title: "Rate",
                                    value: "\(Int.random(in: 12...20))",
                                    unit: "bpm",
                                    icon: "heart.fill"
                                )
                                StatCard(
                                    title: "Depth",
                                    value: "\(Int.random(in: 70...100))",
                                    unit: "%",
                                    icon: "lungs.fill"
                                )
                                StatCard(
                                    title: "Quality",
                                    value: "\(Int.random(in: 80...100))",
                                    unit: "%",
                                    icon: "checkmark.seal.fill"
                                )
                            }
                            .padding(.horizontal)
                            .transition(.moveAndFade)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("BreathEase")
                .toolbar {
                    ToolbarItem(placement: .topTrailing) {
                        NotificationButton()
                    }
                }
            }
        }
    }
}

// Custom transition
extension AnyTransition {
    static var moveAndFade: AnyTransition {
        .asymmetric(
            insertion: .scale.combined(with: .opacity).combined(with: .slide),
            removal: .scale.combined(with: .opacity)
        )
    }
}

// Enhanced StatCard
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.gradient)
                .scaleEffect(showContent ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1), value: showContent)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut.delay(0.2), value: showContent)
            
            Text(value)
                .font(.title2)
                .bold()
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut.delay(0.3), value: showContent)
            
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut.delay(0.4), value: showContent)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .glassMorphic()
        .onAppear {
            showContent = true
        }
    }
}

// Score indicator with animated ring
struct ScoreIndicator: View {
    let score: Double
    @State private var showRing = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                .frame(width: 40, height: 40)
            
            Circle()
                .trim(from: 0, to: showRing ? score / 100 : 0)
                .stroke(
                    score > 80 ? Theme.success : Theme.warning,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1), value: showRing)
        }
        .onAppear {
            showRing = true
        }
    }
}

// Animated notification button
struct NotificationButton: View {
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: {}) {
            ZStack {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.gradient)
                    .symbolEffect(.bounce, options: .repeating, value: isAnimating)
                
                Circle()
                    .fill(Theme.gradient)
                    .frame(width: 8, height: 8)
                    .offset(x: 6, y: -6)
            }
        }
        .onAppear {
            isAnimating = true
        }
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