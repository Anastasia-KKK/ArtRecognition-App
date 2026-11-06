import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var profileVM: ProfileViewModel

    @State private var draftName = ""
    @State private var draftEmail = ""
    @State private var pickedItem: PhotosPickerItem?
    @State private var pickedUIImage: UIImage?
    
    @State private var showPasswordFields = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    (pickedUIImage.map(Image.init(uiImage:)) ?? profileVM.avatarImage)
                        .resizable().scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))

                    PhotosPicker(selection: $pickedItem, matching: .images) {
                        Text("Сменить фото")
                            .font(.custom("EB Garamond", size: 18))
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08)))
                    }
                    .onChange(of: pickedItem) { _, item in
                        Task {
                            if let data = try? await item?.loadTransferable(type: Data.self),
                               let ui = UIImage(data: data) {
                                pickedUIImage = ui
                            }
                        }
                    }

                    TextField("Имя", text: $draftName)
                        .textInputAutocapitalization(.words)
                        .padding(14)
                        .background(.white)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08)))

                    TextField("E-mail", text: $draftEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(.white)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08)))
                    
                    Button(showPasswordFields ? "Отменить смену пароля" : "Изменить пароль") {
                            withAnimation { showPasswordFields.toggle() }
                    }
                    .font(.custom("EB Garamond", size: 18))
                    .foregroundColor(.blue)

                    if showPasswordFields {
                        SecureField("Текущий пароль", text: $currentPassword)
                                .padding(14)
                                .background(.white)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08)))

                    SecureField("Новый пароль", text: $newPassword)
                                .padding(14)
                                .background(.white)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08)))

                    SecureField("Подтвердите пароль", text: $confirmPassword)
                                .padding(14)
                                .background(.white)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.08)))
                                       }

                    Button("Сохранить") { Task { await save() } }
                        .font(.custom("EB Garamond", size: 20)).bold()
                        .frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(isValid ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .disabled(!isValid)
                }
                .padding(20)
            }
            .navigationTitle("Изменить профиль")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
            }
            .task {
                await profileVM.load()
                draftName  = profileVM.data.name
                draftEmail = profileVM.data.email
            }
        }
    }

      private var isValid: Bool {
          !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
          isValidEmail(draftEmail) &&
          (!showPasswordFields || (newPassword == confirmPassword && newPassword.count >= 6))
      }

      private func isValidEmail(_ s: String) -> Bool {
          let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
          return s.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
      }

      private func save() async {
          profileVM.data.name  = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
          profileVM.data.email = draftEmail.trimmingCharacters(in: .whitespacesAndNewlines)
          if let ui = pickedUIImage { profileVM.setAvatar(ui) }

          if showPasswordFields, !newPassword.isEmpty {
              await profileVM.updatePassword(current: currentPassword, new: newPassword)
          }

          await profileVM.save()
          dismiss()
      }
  }
