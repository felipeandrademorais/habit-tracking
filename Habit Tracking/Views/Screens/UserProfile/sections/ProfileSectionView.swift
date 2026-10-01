import SwiftUI

struct ProfileSectionView: View {
    @ObservedObject var profileStore: UserProfileStore
    @Binding var showEditNameModal: Bool
    @State private var showEditAvatarModal = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                LiquidGlassStyle.brandTint.opacity(0.35),
                                Color.color2.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 112, height: 112)

                Image(profileStore.user.avatar.isEmpty ? "no-avatar" : profileStore.user.avatar)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.85), lineWidth: 3)
                    )
                    .shadow(color: AppTheme.softShadow, radius: 8, x: 0, y: 4)
            }
            .onTapGesture {
                showEditAvatarModal = true
            }
            .accessibilityLabel("Editar avatar")

            Button {
                showEditNameModal = true
            } label: {
                HStack(spacing: 6) {
                    Text(profileStore.user.name)
                        .font(AppTheme.title(22))
                        .foregroundColor(.fontSoft)

                    Image(systemName: "pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.fontSoft.opacity(0.45))
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .sheet(isPresented: $showEditAvatarModal) {
            EditAvatarModalView()
                .environmentObject(profileStore)
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
        }
    }
}
