import SwiftUI

class UserProfileStore: ObservableObject {
    @Published var user: User = User(id: UUID(), name: "Click para alterar", avatar: "no-avatar")
    @Published var medals: [Medal] = MedalCatalog.all
    @Published var userMedals: [UserMedal] = []
    @Published var habits: [Habit] = []
    private let userKey = "userKey"

    init() {
        loadUser()
    }
    
    func loadUser() {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return }
        do {
            let decodedUser = try JSONDecoder().decode(User.self, from: data)
            self.user = decodedUser
        } catch {
            print("Erro ao decodificar user: \(error)")
        }
    }

    func saveUser() {
        do {
            let encoded = try JSONEncoder().encode(user)
            UserDefaults.standard.set(encoded, forKey: userKey)
        } catch {
            print("Erro ao codificar user: \(error)")
        }
    }
    
    func updateUserName(_ newName: String) {
           user.name = newName
           saveUser()
    }
    
    func updateUserAvatar(_ newAvatar: String) {
        user.avatar = newAvatar
        saveUser()
    }

    func addMedalToUser(medal: Medal) {
        guard !userMedals.contains(where: { $0.medalID == medal.id }) else { return }
        let userMedal = UserMedal(id: UUID(), medalID: medal.id, userID: user.id, unlockedDate: Date())
        userMedals.append(userMedal)
        saveUser()
    }

    func completedHabitsCount() -> Int {
        habits.filter { !$0.datesCompleted.isEmpty }.count
    }

    func createdHabitsCount() -> Int {
        habits.count
    }

    func getMedalsStatus() -> [MedalStatus] {
        medals.map { medal in
            MedalStatus(medal: medal, isUnlocked: validateMedal(medal))
        }
    }

    private func validateMedal(_ medal: Medal) -> Bool {
        switch medal.criteria {
        case .habitsQuantity(let quantity):
            return completedHabitsCount() >= quantity
        case .habitsCreated(let quantity):
            return createdHabitsCount() >= quantity
        case .totalCompletions, .activityStreak, .perfectDays, .distinctColors, .weekendWarrior:
            return false
        case .custom:
            return false
        }
    }
    
    /// Retorna uma lista de medalhas com status habilitado/desabilitado
    func getMedalsStatus(habitDataStore: HabitDataStore) -> [MedalStatus] {
        medals.map { medal in
            MedalStatus(
                medal: medal,
                isUnlocked: validateMedal(medal, habitDataStore: habitDataStore)
            )
        }
    }

    func getMedalsStatusByCategory(habitDataStore: HabitDataStore) -> [(category: MedalCategory, medals: [MedalStatus])] {
        let statuses = getMedalsStatus(habitDataStore: habitDataStore)
        return MedalCategory.allCases.compactMap { category in
            let items = statuses.filter { $0.medal.category == category }
            return items.isEmpty ? nil : (category, items)
        }
    }

    /// Valida se uma medalha deve ser habilitada
    private func validateMedal(_ medal: Medal, habitDataStore: HabitDataStore) -> Bool {
        switch medal.criteria {
        case .habitsQuantity(let quantity):
            return habitDataStore.completedHabitsCount() >= quantity
        case .habitsCreated(let quantity):
            return habitDataStore.createdHabitsCount() >= quantity
        case .totalCompletions(let quantity):
            return habitDataStore.totalCompletionsCount() >= quantity
        case .activityStreak(let days):
            return habitDataStore.activityStreakDays() >= days
        case .perfectDays(let days):
            return habitDataStore.perfectDaysCount() >= days
        case .distinctColors(let quantity):
            return habitDataStore.distinctColorsCount() >= quantity
        case .weekendWarrior:
            return habitDataStore.hasWeekendWarriorCompletions()
        case .custom:
            return false
        }
    }
}

struct MedalStatus {
    let medal: Medal
    let isUnlocked: Bool
}
