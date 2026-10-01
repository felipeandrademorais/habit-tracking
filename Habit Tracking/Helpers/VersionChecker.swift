import SwiftUI
import StoreKit

@MainActor
class VersionChecker: ObservableObject, @unchecked Sendable {
    static let shared = VersionChecker()
    
    @Published var isUpdateAvailable = false
    
    /// Substitua pelo Apple ID real do seu app (obtido no App Store Connect).
    private let appStoreId = "6741549820"
    
    func checkForUpdate() async {
        guard
            // Versão atual do app (Info.plist -> CFBundleShortVersionString)
            let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            // Consulta ao iTunes Lookup usando o ID do app
            let url = URL(string: "https://itunes.apple.com/lookup?id=\(appStoreId)&country=br")
        else {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(AppStoreResponse.self, from: data)
            
            // Garante que haja pelo menos um resultado na pesquisa
            guard let firstResult = response.results.first else {
                print("Não foi possível encontrar o app com o ID informado.")
                return
            }
            
            let appStoreVersion = firstResult.version
            let isNewer = compareVersions(appStoreVersion, isNewerThan: currentVersion)
            
            // Como a classe está em @MainActor, não é necessário DispatchQueue.main.async
            self.isUpdateAvailable = isNewer
            
        } catch {
            print("Erro ao verificar nova versão na App Store: \(error)")
        }
    }
    
    /// Compara as versões numericamente (ex: "1.2.3") e
    /// retorna `true` se `version1` for mais recente que `version2`.
    private func compareVersions(_ version1: String, isNewerThan version2: String) -> Bool {
        let v1Components = version1.split(separator: ".")
        let v2Components = version2.split(separator: ".")
        
        let maxLength = max(v1Components.count, v2Components.count)
        
        for i in 0..<maxLength {
            let v1 = i < v1Components.count ? Int(v1Components[i]) ?? 0 : 0
            let v2 = i < v2Components.count ? Int(v2Components[i]) ?? 0 : 0
            
            if v1 > v2 {
                return true
            } else if v1 < v2 {
                return false
            }
        }
        return false
    }
    
    /// Abre a página do app na App Store para atualização
    func openAppStore() {
        guard let url = URL(string: "https://apps.apple.com/app/id\(appStoreId)") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Models de resposta da App Store

struct AppStoreResponse: Codable {
    let results: [AppStoreResult]
}

struct AppStoreResult: Codable {
    let version: String
}

// MARK: - View do Alerta de Atualização

struct UpdateAlertView: View {
    @ObservedObject private var versionChecker = VersionChecker.shared
    
    var body: some View {
        ZStack {
            // Se isUpdateAvailable for true, exibe o overlay
            if versionChecker.isUpdateAvailable {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                
                VStack(spacing: 18) {
                    Text("Nova versão disponível")
                        .font(AppTheme.title(18))
                        .foregroundColor(.fontSoft)

                    Text("Uma nova versão do aplicativo está disponível. Atualize agora para continuar usando o app.")
                        .font(AppTheme.caption(14))
                        .foregroundColor(.fontSoft.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: {
                        versionChecker.openAppStore()
                    }) {
                        Text("Atualizar agora")
                            .font(AppTheme.body(14))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(LiquidGlassStyle.brandTint)
                    .padding(.horizontal)
                }
                .padding(22)
                .habitGlassPanel(cornerRadius: LiquidGlassStyle.alertCornerRadius)
                .padding(.horizontal, 40)
            }
        }
        .task {
            // Ao aparecer a View, faz a verificação de versão
            await versionChecker.checkForUpdate()
        }
    }
}
