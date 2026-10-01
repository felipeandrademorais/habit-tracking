import SwiftUI

struct HabitsTodayView: View {
    @EnvironmentObject var dataStore: HabitDataStore
    @State private var isShowingAddHabit: Bool = false
    @State private var habitToEdit: Habit? = nil

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppTheme.pageGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                WeekView(selectedDate: $dataStore.selectedDate)
                    .frame(maxHeight: 108)

                if todaysHabits.isEmpty {
                    EmptyHabitsView {
                        openAddHabit()
                    }
                } else {
                    VStack(spacing: AppTheme.rowSpacing) {
                        DayProgressHeaderView(
                            completedCount: completedCount,
                            totalCount: todaysHabits.count,
                            date: dataStore.selectedDate
                        )
                        .padding(.horizontal, AppTheme.screenPadding)
                        .padding(.top, 12)

                        List {
                            ForEach(Array(todaysHabits.enumerated()), id: \.element.id) { index, habit in
                                HabitRowView(
                                    habit: habit,
                                    selectedDate: dataStore.selectedDate
                                )
                                .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .appearSoftly(delay: Double(index) * 0.04)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        withAnimation(AppTheme.softSpring) {
                                            dataStore.removeHabit(habit)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 18))
                                    }
                                    .tint(.red)

                                    Button {
                                        habitToEdit = habit
                                    } label: {
                                        Image(systemName: "applepencil.gen1")
                                            .font(.system(size: 20))
                                    }
                                    .tint(.color2)
                                }
                            }
                            .onDelete(perform: deleteHabits)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, AppTheme.screenPadding)
                        .scrollEdgeEffectStyle(.soft, for: .bottom)
                    }
                }
            }

            GlassEffectContainer {
                Button(action: openAddHabit) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .frame(width: LiquidGlassStyle.fabSize, height: LiquidGlassStyle.fabSize)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .tint(LiquidGlassStyle.brandTint)
                .shadow(color: LiquidGlassStyle.brandTint.opacity(0.25), radius: 12, x: 0, y: 6)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $isShowingAddHabit) {
            NavigationStack {
                ModalHabitView(startDate: dataStore.selectedDate)
                    .environmentObject(dataStore)
            }
            .presentationDragIndicator(.visible)
        }
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

    private var completedCount: Int {
        todaysHabits.filter { $0.isCompleted(on: dataStore.selectedDate) }.count
    }

    private func openAddHabit() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        isShowingAddHabit = true
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
        HabitsTodayView()
            .environmentObject(HabitDataStore.sampleDataStore)
    }
}
