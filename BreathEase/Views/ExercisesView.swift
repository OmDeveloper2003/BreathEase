import SwiftUI

struct ExercisesView: View {
    @State private var selectedExercise: Exercise?
    @State private var animate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.meshGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Featured exercise with parallax effect
                        GeometryReader { geometry in
                            FeaturedExerciseCard()
                                .rotation3DEffect(
                                    .degrees(geometry.frame(in: .global).minY / -20),
                                    axis: (x: 1, y: 0, z: 0)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 10)
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                        
                        // Exercise categories
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(Exercise.samples) { exercise in
                                ExerciseCard(exercise: exercise)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedExercise = exercise
                                        }
                                    }
                                    .scaleEffect(animate ? 1 : 0.8)
                                    .opacity(animate ? 1 : 0)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Exercises")
                .sheet(item: $selectedExercise) { exercise in
                    ExerciseDetailView(exercise: exercise)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let duration: Int
    let icon: String
    let color: Color
    
    static let samples = [
        Exercise(name: "Deep Breathing", description: "Calm your mind and reduce stress", duration: 5, icon: "lungs.fill", color: .blue),
        Exercise(name: "Box Breathing", description: "Navy SEAL breathing technique", duration: 8, icon: "square", color: .purple),
        Exercise(name: "4-7-8 Technique", description: "Natural tranquilizer for the nervous system", duration: 10, icon: "clock.fill", color: .green),
        Exercise(name: "Alternate Nostril", description: "Balance your energy", duration: 7, icon: "nose.fill", color: .orange)
    ]
}

struct ExerciseCard: View {
    let exercise: Exercise
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: exercise.icon)
                .font(.title)
                .foregroundStyle(exercise.color)
                .symbolEffect(.bounce, options: .repeat(2), value: isHovered)
            
            Text(exercise.name)
                .font(.headline)
            
            Text("\(exercise.duration) min")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .scaleEffect(isHovered ? 1.05 : 1)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
    }
}

struct FeaturedExerciseCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Featured Exercise")
                .font(.title2)
                .bold()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Box Breathing")
                        .font(.headline)
                    Text("Perfect for stress relief")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(Theme.gradient)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "play.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .scaleEffect(isAnimating ? 1.2 : 1)
                            .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)
                    }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            isAnimating = true
        }
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) var dismiss
    @State private var isStarted = false
    @State private var progress: CGFloat = 0
    
    var body: some View {
        ZStack {
            Theme.meshGradient
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Exercise icon with animated ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Theme.gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    Circle()
                        .fill(exercise.color.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .overlay {
                            Image(systemName: exercise.icon)
                                .font(.system(size: 40))
                                .foregroundStyle(exercise.color)
                                .symbolEffect(.bounce, options: .repeating, value: isStarted)
                        }
                }
                
                // Exercise info
                VStack(spacing: 10) {
                    Text(exercise.name)
                        .font(.title2)
                        .bold()
                    Text(exercise.description)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                // Start button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isStarted.toggle()
                        if isStarted {
                            withAnimation(.linear(duration: Double(exercise.duration * 60))) {
                                progress = 1
                            }
                        } else {
                            progress = 0
                        }
                    }
                }) {
                    Text(isStarted ? "Stop Exercise" : "Start Exercise")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(isStarted ? Theme.error.gradient : Theme.gradient)
                        )
                        .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
} 