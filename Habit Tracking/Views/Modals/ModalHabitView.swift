import SwiftUI
import UserNotifications

struct ModalHabitView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    @Environment(\.presentationMode) var presentationMode
    
    private let isEdit: Bool
    private let habitToEdit: Habit?
    
    @State private var nome: String
    @State private var cor: Color
    @State private var dataInicio: Date
    @State private var selectedCycle: Repeticao
    @State private var selectedDays: [Int]
    @State private var iconName: String
    @State private var showIconPicker: Bool = false
    @State private var notificationsEnabled: Bool = false
    @State private var notificationTime: Date = Date()
    
    init(habit: Habit? = nil, startDate: Date = Date()) {
        self.habitToEdit = habit
        self.isEdit = habit != nil
        
        _nome = State(initialValue: habit?.nome ?? "")
        
        if let habit = habit {
            if let index = predefinedColors.firstIndex(where: { "color\((predefinedColors.firstIndex(of: $0) ?? 0) + 1)" == habit.cor }) {
                _cor = State(initialValue: predefinedColors[index])
            } else {
                _cor = State(initialValue: predefinedColors.first ?? .clear)
            }
            _notificationsEnabled = State(initialValue: habit.notificationsEnabled)
            if let notificationTime = habit.notificationTime {
                _notificationTime = State(initialValue: notificationTime)
            }
        } else {
            _cor = State(initialValue: predefinedColors.first ?? .clear)
        }
        
        _dataInicio = State(initialValue: habit?.dataInicio ?? startDate)
        _selectedCycle = State(initialValue: habit?.repeticoes ?? .daily)
        _selectedDays = State(initialValue: habit?.diasDoHabito ?? [1, 2, 3, 4, 5])
        _iconName = State(initialValue: habit?.icon ?? "⭐️")
    }
    
    var body: some View {
        Form {
            Section {
                VStack(spacing: 8) {
                    Text(iconName)
                        .font(.system(size: 64))
                        .frame(width: 96, height: 96)
                        .background(
                            Circle()
                                .fill(cor.opacity(0.55))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.7), lineWidth: 2)
                        )
                        .shadow(color: AppTheme.softShadow, radius: 8, x: 0, y: 4)

                    Text("Toque para escolher um ícone")
                        .font(AppTheme.micro(11))
                        .foregroundColor(.fontSoft.opacity(0.55))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .onTapGesture {
                    showIconPicker = true
                }
                .sheet(isPresented: $showIconPicker) {
                    IconPickerView(
                        selectedIcon: $iconName,
                        isPresented: $showIconPicker
                    )
                    .presentationDetents([.fraction(0.4)])
                    .presentationDragIndicator(.visible)
                }
            }
            .listRowBackground(Color.clear)
            
            Section {
                TextField("Nome do hábito", text: $nome)
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .padding(.vertical, 10)
                    .overlay(
                        Rectangle()
                            .frame(height: 1.8)
                            .foregroundColor(.fontSoft)
                            .padding(.top, 40),
                        alignment: .bottom
                    )
                    .padding(.bottom, 12)
            }
            
            Section {
                DatePicker(
                    "Data de início",
                    selection: $dataInicio,
                    displayedComponents: [.date]
                )
                .font(Font.custom("Poppins-Regular", size: 14))
                .foregroundColor(.fontSoft)
                .padding(.vertical, 10)
            }
            
            Section {
                TaskCycleCardView(
                    selectedCycle: $selectedCycle,
                    selectedDays: $selectedDays
                )
                .padding()
            }
            
            Section {
                LazyHGrid(rows: [GridItem(.fixed(40), spacing: 20)], spacing: 20) {
                    ForEach(predefinedColors, id: \.self) { color in
                        ColorCircleSelector(
                            color: color,
                            isSelected: cor == color
                        ) {
                            cor = color
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .listRowBackground(Color.clear)
            
            Section {
                Toggle(isOn: $notificationsEnabled) {
                    Text("Habilitar Notificações")
                        .font(Font.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.fontSoft)
                }
                .onChange(of: notificationsEnabled) { oldValue, newValue in
                    if newValue {
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            if settings.authorizationStatus != .authorized {
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
                            }
                        }
                    }
                }
                
                if notificationsEnabled {
                    DatePicker(
                        "Horário da Notificação",
                        selection: $notificationTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.fontSoft)
                }
            }
            
            Section {
                Button(action: addOrUpdateHabit) {
                    Text(isEdit ? "Salvar" : "Adicionar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .tint(LiquidGlassStyle.brandTint)
                .disabled(nome.isEmpty)
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    private func addOrUpdateHabit() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        guard let index = predefinedColors.firstIndex(of: cor) else { return }
        let colorName = "color\(index + 1)"
        
        if isEdit, let habit = habitToEdit {
            let updatedHabit = Habit(
                id: habit.id,
                nome: nome,
                cor: colorName,
                dataInicio: dataInicio,
                repeticoes: selectedCycle,
                diasDoHabito: selectedDays,
                icon: iconName,
                notificationsEnabled: notificationsEnabled,
                notificationTime: notificationsEnabled ? notificationTime : nil
            )
            dataStore.updateHabit(updatedHabit)
        } else {
            let newHabit = Habit(
                nome: nome,
                cor: colorName,
                dataInicio: dataInicio,
                repeticoes: selectedCycle,
                diasDoHabito: selectedDays,
                icon: iconName,
                notificationsEnabled: notificationsEnabled,
                notificationTime: notificationsEnabled ? notificationTime : nil
            )
            dataStore.addHabit(newHabit)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Preview
struct ModalHabitView_Previews: PreviewProvider {
    static var previews: some View {
        let dataStore = HabitDataStore()
        
        return NavigationView {
            ModalHabitView()
                .environmentObject(dataStore)
        }
    }
}
