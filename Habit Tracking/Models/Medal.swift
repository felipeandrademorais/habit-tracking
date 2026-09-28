import SwiftUI

struct Medal: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let unlockCondition: String
    let criteria: MedalCriteria
    let category: MedalCategory
}

enum MedalCategory: String, Codable, CaseIterable {
    case beginnings = "Começo"
    case creation = "Criação"
    case consistency = "Consistência"
    case mastery = "Maestria"
    case exploration = "Exploração"
}

enum MedalCriteria: Codable, Equatable {
    /// Habits that were completed at least once.
    case habitsQuantity(Int)
    /// Habits created (regardless of completions).
    case habitsCreated(Int)
    /// Total check-ins across all habits.
    case totalCompletions(Int)
    /// Consecutive days (ending today) with at least one completion.
    case activityStreak(Int)
    /// Days where every scheduled habit was completed.
    case perfectDays(Int)
    /// Distinct habit colors in use.
    case distinctColors(Int)
    /// At least one completion on Saturday and one on Sunday (lifetime).
    case weekendWarrior
    case custom(String)
}

enum MedalCatalog {
    static let all: [Medal] = beginnings + creation + consistency + mastery + exploration

    // MARK: - Começo

    private static let beginnings: [Medal] = [
        medal(
            "11111111-1111-4111-8111-111111111101",
            name: "Primeiro Passo",
            description: "Crie seu primeiro hábito",
            icon: "sparkles",
            condition: "Crie 1 hábito",
            criteria: .habitsCreated(1),
            category: .beginnings
        ),
        medal(
            "11111111-1111-4111-8111-111111111102",
            name: "Iniciante",
            description: "Complete um hábito pela primeira vez",
            icon: "star.fill",
            condition: "Complete 1 hábito",
            criteria: .habitsQuantity(1),
            category: .beginnings
        ),
        medal(
            "11111111-1111-4111-8111-111111111103",
            name: "Aquecendo",
            description: "Faça 5 check-ins no total",
            icon: "flame.fill",
            condition: "5 check-ins",
            criteria: .totalCompletions(5),
            category: .beginnings
        ),
        medal(
            "11111111-1111-4111-8111-111111111104",
            name: "Dia Perfeito",
            description: "Complete 100% dos hábitos em um dia",
            icon: "sun.max.fill",
            condition: "1 dia perfeito",
            criteria: .perfectDays(1),
            category: .beginnings
        )
    ]

    // MARK: - Criação

    private static let creation: [Medal] = [
        medal(
            "22222222-2222-4222-8222-222222222201",
            name: "Colecionador",
            description: "Tenha 3 hábitos ativos",
            icon: "square.stack.3d.up.fill",
            condition: "Crie 3 hábitos",
            criteria: .habitsCreated(3),
            category: .creation
        ),
        medal(
            "22222222-2222-4222-8222-222222222202",
            name: "Organizador",
            description: "Monte uma rotina com 5 hábitos",
            icon: "list.bullet.clipboard.fill",
            condition: "Crie 5 hábitos",
            criteria: .habitsCreated(5),
            category: .creation
        ),
        medal(
            "22222222-2222-4222-8222-222222222203",
            name: "Arquiteto",
            description: "Crie 10 hábitos diferentes",
            icon: "hammer.fill",
            condition: "Crie 10 hábitos",
            criteria: .habitsCreated(10),
            category: .creation
        ),
        medal(
            "22222222-2222-4222-8222-222222222204",
            name: "Mestre das Cores",
            description: "Use 4 cores diferentes nos hábitos",
            icon: "paintpalette.fill",
            condition: "4 cores distintas",
            criteria: .distinctColors(4),
            category: .creation
        ),
        medal(
            "22222222-2222-4222-8222-222222222205",
            name: "Arco-Íris",
            description: "Use todas as 5 cores de hábitos",
            icon: "rainbow",
            condition: "5 cores distintas",
            criteria: .distinctColors(5),
            category: .creation
        )
    ]

    // MARK: - Consistência

    private static let consistency: [Medal] = [
        medal(
            "33333333-3333-4333-8333-333333333301",
            name: "Sequência",
            description: "Mantenha atividade por 3 dias seguidos",
            icon: "arrow.triangle.2.circlepath",
            condition: "Streak de 3 dias",
            criteria: .activityStreak(3),
            category: .consistency
        ),
        medal(
            "33333333-3333-4333-8333-333333333302",
            name: "Semana Firme",
            description: "Atividade em 7 dias consecutivos",
            icon: "calendar",
            condition: "Streak de 7 dias",
            criteria: .activityStreak(7),
            category: .consistency
        ),
        medal(
            "33333333-3333-4333-8333-333333333303",
            name: "Quinzena",
            description: "14 dias seguidos de atividade",
            icon: "calendar.badge.checkmark",
            condition: "Streak de 14 dias",
            criteria: .activityStreak(14),
            category: .consistency
        ),
        medal(
            "33333333-3333-4333-8333-333333333304",
            name: "Mês de Foco",
            description: "30 dias consecutivos de atividade",
            icon: "crown.fill",
            condition: "Streak de 30 dias",
            criteria: .activityStreak(30),
            category: .consistency
        ),
        medal(
            "33333333-3333-4333-8333-333333333305",
            name: "Lenda",
            description: "100 dias consecutivos de atividade",
            icon: "trophy.fill",
            condition: "Streak de 100 dias",
            criteria: .activityStreak(100),
            category: .consistency
        ),
        medal(
            "33333333-3333-4333-8333-333333333306",
            name: "Guerreiro de Fim de Semana",
            description: "Complete hábitos no sábado e no domingo",
            icon: "beach.umbrella.fill",
            condition: "Check-ins no sábado e domingo",
            criteria: .weekendWarrior,
            category: .consistency
        )
    ]

    // MARK: - Maestria

    private static let mastery: [Medal] = [
        medal(
            "44444444-4444-4444-8444-444444444401",
            name: "Progresso",
            description: "Complete 10 hábitos diferentes ao menos uma vez",
            icon: "chart.line.uptrend.xyaxis",
            condition: "10 hábitos com check-in",
            criteria: .habitsQuantity(10),
            category: .mastery
        ),
        medal(
            "44444444-4444-4444-8444-444444444402",
            name: "Em Ritmo",
            description: "Acumule 25 check-ins",
            icon: "bolt.fill",
            condition: "25 check-ins",
            criteria: .totalCompletions(25),
            category: .mastery
        ),
        medal(
            "44444444-4444-4444-8444-444444444403",
            name: "Comprometido",
            description: "Acumule 50 check-ins",
            icon: "heart.fill",
            condition: "50 check-ins",
            criteria: .totalCompletions(50),
            category: .mastery
        ),
        medal(
            "44444444-4444-4444-8444-444444444404",
            name: "Centurião",
            description: "Acumule 100 check-ins",
            icon: "shield.fill",
            condition: "100 check-ins",
            criteria: .totalCompletions(100),
            category: .mastery
        ),
        medal(
            "44444444-4444-4444-8444-444444444405",
            name: "Imparável",
            description: "Acumule 250 check-ins",
            icon: "rocket.fill",
            condition: "250 check-ins",
            criteria: .totalCompletions(250),
            category: .mastery
        ),
        medal(
            "44444444-4444-4444-8444-444444444406",
            name: "Lenda Viva",
            description: "Acumule 500 check-ins",
            icon: "medal.fill",
            condition: "500 check-ins",
            criteria: .totalCompletions(500),
            category: .mastery
        ),
        medal(
            "44444444-4444-4444-8444-444444444407",
            name: "Perfeccionista",
            description: "Alcance 5 dias perfeitos",
            icon: "checkmark.seal.fill",
            condition: "5 dias perfeitos",
            criteria: .perfectDays(5),
            category: .mastery
        ),
        medal(
            "44444444-4444-4444-8444-444444444408",
            name: "Excelência",
            description: "Alcance 15 dias perfeitos",
            icon: "rosette",
            condition: "15 dias perfeitos",
            criteria: .perfectDays(15),
            category: .mastery
        ),
        medal(
            "44444444-4444-4444-8444-444444444409",
            name: "Domínio Total",
            description: "Alcance 30 dias perfeitos",
            icon: "seal.fill",
            condition: "30 dias perfeitos",
            criteria: .perfectDays(30),
            category: .mastery
        )
    ]

    // MARK: - Exploração

    private static let exploration: [Medal] = [
        medal(
            "55555555-5555-4555-8555-555555555501",
            name: "Trio",
            description: "Complete 3 hábitos diferentes",
            icon: "person.3.fill",
            condition: "3 hábitos com check-in",
            criteria: .habitsQuantity(3),
            category: .exploration
        ),
        medal(
            "55555555-5555-4555-8555-555555555502",
            name: "Equipe Completa",
            description: "Complete 5 hábitos diferentes",
            icon: "star.circle.fill",
            condition: "5 hábitos com check-in",
            criteria: .habitsQuantity(5),
            category: .exploration
        ),
        medal(
            "55555555-5555-4555-8555-555555555503",
            name: "Maratonista",
            description: "Faça 60 check-ins no total",
            icon: "figure.run",
            condition: "60 check-ins",
            criteria: .totalCompletions(60),
            category: .exploration
        ),
        medal(
            "55555555-5555-4555-8555-555555555504",
            name: "Constante",
            description: "Mantenha 21 dias de atividade",
            icon: "infinity",
            condition: "Streak de 21 dias",
            criteria: .activityStreak(21),
            category: .exploration
        ),
        medal(
            "55555555-5555-4555-8555-555555555505",
            name: "Brilhante",
            description: "Alcance 10 dias perfeitos",
            icon: "sparkle",
            condition: "10 dias perfeitos",
            criteria: .perfectDays(10),
            category: .exploration
        )
    ]

    private static func medal(
        _ id: String,
        name: String,
        description: String,
        icon: String,
        condition: String,
        criteria: MedalCriteria,
        category: MedalCategory
    ) -> Medal {
        Medal(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            description: description,
            icon: icon,
            unlockCondition: condition,
            criteria: criteria,
            category: category
        )
    }
}
