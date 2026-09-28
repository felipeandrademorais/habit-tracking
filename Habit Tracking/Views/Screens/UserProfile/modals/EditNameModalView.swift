import SwiftUI

struct EditNameModalView: View {
    @EnvironmentObject var profileStore: UserProfileStore
    @State private var newName: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Text("Editar Nome")
                .font(Font.custom("Poppins-Regular", size: 16))
            
            Section {
                TextField("Seu nome", text: $newName)
                    .font(Font.custom("Poppins-Regular", size: 14))
                    .padding(.vertical, 10)
                    .overlay(
                        Rectangle()
                            .frame(height: 1.8)
                            .foregroundColor(.blackSoft.opacity(0.4))
                            .padding(.top, 40),
                        alignment: .bottom
                    )
                    .padding(.bottom, 12)
            }
            
            Section {
                Button(action: addName) {
                    Text("Confirmar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .tint(LiquidGlassStyle.brandTint)
                .disabled(newName.isEmpty && newName == profileStore.user.name)
            }
            .listRowBackground(Color.clear)
        }
        .onAppear {
            newName = profileStore.user.name
        }
        .scrollContentBackground(.hidden)
    }
    
    private func addName() {
        profileStore.updateUserName(newName)
        dismiss()
    }
}
