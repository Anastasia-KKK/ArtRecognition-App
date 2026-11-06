import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginError: String?
    @State private var isLoggedIn = false
    @EnvironmentObject var profileVM: ProfileViewModel

    @AppStorage("appLanguage") private var selectedLanguage = "ru"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Язык и заголовок
                    HStack {
                        Spacer()
                        Button {
                            selectedLanguage = (selectedLanguage == "ru") ? "en" : "ru"
                        }
                        label: {
                            Text(selectedLanguage == "ru" ? "🇬🇧" : "🇷🇺")
                                .font(.system(size: 30))
                        }
                        .accessibilityIdentifier("languageSwitchButton")
                    }
                    .overlay(
                        Text("Вход")
                            .font(.custom("EB Garamond", size: 35))
                            .fontWeight(.semibold)
                            .accessibilityIdentifier("loginTitle"),
                        alignment: .center
                    )
                    .padding(.top, 30)

                    // Email
                    CustomTextField(title: "Email", text: $email, keyboardType: .emailAddress)

                    // Пароль
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Пароль")
                            .font(.custom("EB Garamond", size: 18))
                        SecureField("", text: $password)
                            .padding()
                            .frame(height: 45)
                            .background(Color(white: 0.95))
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .accessibilityIdentifier("passwordField")
                    }

                    // Общая ошибка
                    if let error = loginError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Кнопка входа
                    Button(action: loginUser) {
                        Text("Войти")
                            .font(.custom("EB Garamond", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .accessibilityIdentifier("loginButton")
                    }
                    .padding(.top, 10)

                    // Регистрация
                    HStack {
                        Text("Нет аккаунта?")
                            .foregroundColor(.gray)
                            .font(.custom("EB Garamond", size: 16))

                        NavigationLink(destination: RegistrationView()) {
                            Text("Зарегистрироваться")
                                .font(.custom("EB Garamond", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 30)
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                MainView()
            }
            .ignoresSafeArea(.keyboard)
        }
    }

    func loginUser() {
        loginError = nil

        guard let url = URL(string: "\(API.baseURL)/auth/login") else {
            loginError = "Ошибка подключения"
            return
        }

        let credentials = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: credentials)
        } catch {
            loginError = "Ошибка данных"
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let _ = error {
                    loginError = "Сервер недоступен"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    loginError = "Неверный email или пароль"
                    return
                }

                // Функция парсинга id
                func extractUserID(from data: Data?) throws -> Int {
                    guard let data = data else {
                        throw URLError(.badServerResponse)
                    }

                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    guard let id = json?["id"] as? Int else {
                        throw URLError(.badServerResponse)
                    }

                    return id
                }

                // Загружаем профиль после успешного входа
                Task {
                    do {
                        let userID = try extractUserID(from: data)
                        try await AppStorageProfileRepository().save(
                            UserProfile(id: userID, name: "", email: "", language: "ru", avatarData: nil)
                        )
                        await profileVM.load()
                        isLoggedIn = true
                    } catch {
                        loginError = "Ошибка загрузки профиля"
                        print("Ошибка извлечения userID: \(error)")
                    }
                }
            }
        }.resume()
    }
}

struct CustomTextField: View {
    var title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("EB Garamond", size: 18))
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .padding()
                .frame(height: 45)
                .background(Color(white: 0.95))
                .cornerRadius(10)
                .accessibilityIdentifier(
                                    title == "Email" ? "emailField" : "\(title)Field"
                                )
        }
    }
}

