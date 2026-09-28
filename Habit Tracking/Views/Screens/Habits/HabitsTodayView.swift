import SwiftUI

struct HabitsTodayView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    @State private var isShowingAddHabit: Bool = false
    @State private var habitToEdit: Habit? = nil
    @State private var showAnimation: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                WeekView(selectedDate: $dataStore.selectedDate)
                .frame(maxHeight: 95)
                
                if (todaysHabits.isEmpty) {
                    Spacer()
                    Image("Woman")
                        .resizable()
                        .scaledToFit()
                        .padding(40)
                    
                    Spacer()
                } else {
                    List {
                        ForEach(todaysHabits) { habit in
                            HabitRowView(
                                habit: habit,
                                selectedDate: dataStore.selectedDate
                            )
                            .padding(.vertical, 8)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(
                                Color.white.opacity(0.001)
                            )
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    dataStore.removeHabit(habit)
                                } label: {
                                    ZStack {
                                        VStack(spacing: 4) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 18))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .tint(.red)
                                Button {
                                    habitToEdit = habit
                                } label: {
                                    ZStack {
                                        VStack(spacing: 4) {
                                            Image(systemName: "applepencil.gen1")
                                                .font(.system(size: 22))
                                                .foregroundColor(.white)
                                        }
                                        .tint(.color2)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: deleteHabits)
                    }
                    .listStyle(.plain)
                    .listRowSeparator(.hidden)
                    .padding()
                    .scrollEdgeEffectStyle(.soft, for: .bottom)
                }
            }
            
            GlassEffectContainer {
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    isShowingAddHabit = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .frame(width: LiquidGlassStyle.fabSize, height: LiquidGlassStyle.fabSize)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .tint(LiquidGlassStyle.brandTint)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
            
        }
        // Modal para adicionar novo hábito
        .sheet(isPresented: $isShowingAddHabit) {
            NavigationStack {
                ModalHabitView(startDate: dataStore.selectedDate)
                    .environmentObject(dataStore)
            }
            .presentationDragIndicator(.visible)
        }
        // Modal para editar hábito (disparado ao atribuir um valor a habitToEdit)
        .sheet(item: $habitToEdit) { habit in
            NavigationStack {
                ModalHabitView(habit: habit)
                    .environmentObject(dataStore)
            }
            .presentationDragIndicator(.visible)
        }
    }
    
    private var todaysHabits: [Habit] {
        dataStore.habits(for: dataStore.selectedDate)
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        offsets.forEach { index in
            let habit = todaysHabits[index]
            dataStore.removeHabit(habit)
        }
    }
}

struct HabitsTodayView_Previews: PreviewProvider {
    static var previews: some View {
        return HabitsTodayView()
            .environmentObject(HabitDataStore.sampleDataStore)
    }
}
