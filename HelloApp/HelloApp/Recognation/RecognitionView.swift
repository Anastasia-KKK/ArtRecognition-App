import SwiftUI

struct RecognitionView: View {

    @State private var isLoading = false
    @State private var recognizedArtworkID: Int?
    @State private var showError = false

    var body: some View {
        ZStack {

            CameraView { image in
                uploadImage(image)
            }
            .ignoresSafeArea()

            if isLoading {
                VStack {
                    ProgressView()
                    Text("Распознаем...")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { recognizedArtworkID != nil },
            set: { _ in }
        )) {
            if let id = recognizedArtworkID {
                ArtworkDetailView(artworkID: id)
            }
        }
        .alert("Ошибка", isPresented: $showError) {
            Button("ОК", role: .cancel) {}
        } message: {
            Text("Картина не распознана")
        }
    }

    func uploadImage(_ image: UIImage) {
        isLoading = true
        recognizedArtworkID = nil 
        showError = false

        guard let url = URL(string: "\(API.baseURL)/recognize") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }

        var body = Data()

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    isLoading = false
                }
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    isLoading = false

                    if let id = json["id"] as? Int {
                        recognizedArtworkID = id
                    } else {
                        showError = true
                    }
                }
            }
        }.resume()
    }
}
