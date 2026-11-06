import SwiftUI

struct RegistrationView: View {
    // Данные пользователя
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var profileImage: Image? = Image(systemName: "person.circle.fill")
    @State private var showingImagePicker = false
    @State private var isRegistered = false
    @AppStorage("appLanguage") private var selectedLanguage = "ru"
    @EnvironmentObject var profileVM: ProfileViewModel

    // Ошибки
    @State private var nameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?

    // Фокус поля
    @FocusState private var focusedField: Field?
    @State private var didSubmit = false
    enum Field { case name, email, password, confirmPassword }

    // Словарь перевода
    var localized: [String: String] {
        selectedLanguage == "ru" ? [
            "title": "Регистрация",
            "upload": "Загрузить фотографию",
            "name": "Имя",
            "email": "Email",
            "password": "Пароль",
            "repeatPassword": "Повторите пароль",
            "register": "Зарегистрироваться"
        ] : [
            "title": "Register",
            "upload": "Upload photo",
            "name": "Name",
            "email": "Email",
            "password": "Password",
            "repeatPassword": "Repeat password",
            "register": "Register"
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 13) {
                        Text(localized["title"] ?? "")
                            .font(.custom("EB Garamond", size: 30))
                            .fontWeight(.semibold)
                            .padding(.top, 10)

                        profileImage?
                            .resizable()
                            .scaledToFill()
                            .frame(width: 130, height: 130)
                            .foregroundColor(.gray)
                            .clipShape(Circle())
                            .padding(.top, 10)

                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text(localized["upload"] ?? "")
                                .font(.custom("EB Garamond", size: 16))
                                .foregroundColor(.blue)
                        }

                        Group {
                            customInputField(text: localized["name"] ?? "", textBinding: $name, error: $nameError, field: .name)
                            customInputField(text: localized["email"] ?? "", textBinding: $email, error: $emailError, field: .email, keyboardType: .emailAddress)
                            customSecureField(text: localized["password"] ?? "", textBinding: $password, error: $passwordError, field: .password)
                            customSecureField(text: localized["repeatPassword"] ?? "", textBinding: $confirmPassword, error: $confirmPasswordError, field: .confirmPassword)
                        }

                        Button(action: {
                            didSubmit = true
                            validateAll()
                            if isFormValid {
                                registerUser()
                            }
                        }) {
                            Text(localized["register"] ?? "")
                                .font(.custom("EB Garamond", size: 20))
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 30)
                    .id("formStart")
                }
                .onTapGesture {
                    hideKeyboard()
                }
                .sheet(isPresented: $showingImagePicker) {
                    Text("Загрузка фото пока не реализована")
                        .font(.custom("EB Garamond", size: 20))
                        .padding()
                }
                .navigationDestination(isPresented: $isRegistered) {
                    MainView()
                }
            }
        }
    }
    // Проверка валидации
    var isFormValid: Bool {
        nameError == nil &&
        emailError == nil &&
        passwordError == nil &&
        confirmPasswordError == nil &&
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty
    }


    func validateAll() {
        validateName()
        validateEmail()
        validatePassword()
        validateConfirmPassword()
    }

    func validateName() {
        nameError = name.trimmingCharacters(in: .whitespaces).isEmpty ? "Введите имя" : nil
    }

    func validateEmail() {
        let isValid = ValidationService.isValidEmail(email)
        emailError = isValid ? nil : "Введите корректный email"
    }
    
    func validatePassword() {
        if password.count < 6 {
            passwordError = "Пароль должен быть от 6 символов"
        } else if password.rangeOfCharacter(from: .decimalDigits) == nil ||
                    password.rangeOfCharacter(from: .letters) == nil {
            passwordError = "Пароль должен содержать буквы и цифры"
        } else {
            passwordError = nil
        }
    }

    func validateConfirmPassword() {
        confirmPasswordError = (password == confirmPassword) ? nil : "Пароли не совпадают"
    }

    func registerUser() {
        guard let url = URL(string: "\(API.baseURL)/auth/register") else { return }
        
        let user = UserRegister(
            name: name,
            email: email,
            password: password,
            language: selectedLanguage
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let userID = json["id"] as? Int {
                        
                        UserDefaults.standard.set(userID, forKey: "profile_id")
                        
                        DispatchQueue.main.async {
                            Task {
                                await profileVM.load()
                                isRegistered = true     
                            }
                        }
                    } else {
                        print("❌ Не удалось извлечь id из ответа: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                }.resume()
            }

    @ViewBuilder
    func customInputField(text: String, textBinding: Binding<String>, error: Binding<String?>, field: Field, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .font(.custom("EB Garamond", size: 18))
            TextField("", text: textBinding)
                .keyboardType(keyboardType)
                .focused($focusedField, equals: field)
                .padding()
                .background(Color(white: 0.95))
                .cornerRadius(10)
            if didSubmit, let err = error.wrappedValue {
                Text(err).foregroundColor(.red).font(.caption)
            }
        }
    }

    @ViewBuilder
    func customSecureField(text: String, textBinding: Binding<String>, error: Binding<String?>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .font(.custom("EB Garamond", size: 18))
            SecureField("", text: textBinding)
                .focused($focusedField, equals: field)
                .padding()
                .background(Color(white: 0.95))
                .cornerRadius(10)
            if didSubmit, let err = error.wrappedValue {
                Text(err).foregroundColor(.red).font(.caption)
            }
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct UserRegister: Codable {
    let name: String
    let email: String
    let password: String
    let language: String
}
