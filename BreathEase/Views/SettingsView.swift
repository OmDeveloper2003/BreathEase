import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var showingProfile = false
    @State private var selectedTime = Date()
    @State private var animate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.meshGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Section
                        Button(action: { showingProfile.toggle() }) {
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(Theme.gradient)
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.white)
                                        .symbolEffect(.bounce, value: animate)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("John Doe")
                                        .font(.title3)
                                        .bold()
                                    Text("Premium Member")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .glassMorphic()
                        }
                        .buttonStyle(.plain)
                        
                        // Settings Sections
                        VStack(spacing: 20) {
                            SettingsSection(title: "Appearance") {
                                SettingsToggleRow(
                                    title: "Dark Mode",
                                    icon: "moon.fill",
                                    color: .purple,
                                    isOn: $isDarkMode
                                )
                                
                                ColorThemePicker()
                            }
                            
                            SettingsSection(title: "Notifications") {
                                SettingsToggleRow(
                                    title: "Enable Notifications",
                                    icon: "bell.fill",
                                    color: .blue,
                                    isOn: $notificationsEnabled
                                )
                                
                                if notificationsEnabled {
                                    DatePicker("Reminder Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                        .padding(.horizontal)
                                        .transition(.moveAndFade)
                                }
                            }
                            
                            SettingsSection(title: "Data & Privacy") {
                                SettingsLinkRow(
                                    title: "Export Health Data",
                                    icon: "square.and.arrow.up",
                                    color: .green
                                )
                                
                                SettingsLinkRow(
                                    title: "Privacy Policy",
                                    icon: "hand.raised.fill",
                                    color: .blue
                                )
                                
                                SettingsLinkRow(
                                    title: "Terms of Service",
                                    icon: "doc.text.fill",
                                    color: .orange
                                )
                            }
                            
                            SettingsSection(title: "About") {
                                HStack {
                                    Text("Version")
                                    Spacer()
                                    Text("1.0.0")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Settings")
            }
        }
        .onAppear {
            animate = true
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 2) {
                content
            }
            .glassMorphic()
        }
    }
}

struct SettingsToggleRow: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool
    @State private var animate = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .symbolEffect(.bounce, value: animate)
            
            Text(title)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Theme.gradient)
        }
        .padding(.horizontal)
        .onAppear { animate = true }
        .onChange(of: isOn) { animate = true }
    }
}

struct SettingsLinkRow: View {
    let title: String
    let icon: String
    let color: Color
    @State private var isPressed = false
    
    var body: some View {
        Button(action: { isPressed.toggle() }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                
                Text(title)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

struct ColorThemePicker: View {
    let themes: [(String, Color)] = [
        ("Blue", .blue),
        ("Purple", .purple),
        ("Pink", .pink),
        ("Orange", .orange)
    ]
    @State private var selectedTheme = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(0..<themes.count, id: \.self) { index in
                    Circle()
                        .fill(themes[index].1.gradient)
                        .frame(width: 30, height: 30)
                        .overlay {
                            if index == selectedTheme {
                                Circle()
                                    .strokeBorder(.white, lineWidth: 2)
                                    .padding(2)
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTheme = index
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.meshGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Circle()
                        .fill(Theme.gradient)
                        .frame(width: 120, height: 120)
                        .overlay {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 100))
                                .foregroundStyle(.white)
                        }
                        .shadow(radius: 10)
                    
                    VStack(spacing: 8) {
                        Text("John Doe")
                            .font(.title)
                            .bold()
                        Text("Premium Member")
                            .foregroundStyle(.secondary)
                    }
                    
                    // Stats
                    HStack(spacing: 30) {
                        StatView(value: "28", title: "Sessions")
                        StatView(value: "85%", title: "Avg. Score")
                        StatView(value: "12h", title: "Total Time")
                    }
                    
                    Button("Edit Profile") {
                        // Add edit profile action
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.gradient)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct StatView: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 80)
        .padding()
        .glassMorphic()
    }
} 