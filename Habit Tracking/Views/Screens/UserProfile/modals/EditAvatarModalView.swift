import SwiftUI

struct EditAvatarModalView: View {
    @EnvironmentObject var profileStore: UserProfileStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedAvatar: String = ""
    
    private let avatarOptions = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5"]
    
    var body: some View {
        Form {
            Text("Escolher Avatar")
                .font(Font.custom("Poppins-Regular", size: 16))
            
            Section {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(avatarOptions, id: \.self) { avatar in
                        Image(avatar)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(selectedAvatar == avatar ? Color.fontSoft : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedAvatar = avatar
                            }
                    }
                }
                .padding(.vertical)
            }
            
            Section {
                Button(action: updateAvatar) {
                    Text("Confirmar")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .tint(LiquidGlassStyle.brandTint)
                .disabled(selectedAvatar.isEmpty)
            }
            .listRowBackground(Color.clear)
        }
        .onAppear {
            selectedAvatar = profileStore.user.avatar
        }
        .scrollContentBackground(.hidden)
    }
    
    private func updateAvatar() {
        profileStore.updateUserAvatar(selectedAvatar)
        dismiss()
    }
}
