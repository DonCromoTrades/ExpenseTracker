import SwiftUI
import ReceiptScanner

struct ReceiptCaptureView: View {
    @State private var showPicker = false
    @State private var image: UIImage?
    @State private var recognizedLines: [String] = []
    @State private var isScanning = false
    @State private var pickerSource: UIImagePickerController.SourceType = .camera

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            if isScanning {
                ProgressView()
            }
            List {
                ForEach(recognizedLines.indices, id: \.self) { index in
                    TextField("Line", text: Binding(
                        get: { recognizedLines[index] },
                        set: { recognizedLines[index] = $0 }
                    ))
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    pickerSource = .camera
                    showPicker = true
                } label: {
                    Label("Camera", systemImage: "camera")
                }
                Button {
                    pickerSource = .photoLibrary
                    showPicker = true
                } label: {
                    Label("Photos", systemImage: "photo.on.rectangle")
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(sourceType: pickerSource) { uiImage in
                self.image = uiImage
                scan(uiImage)
            }
        }
    }

    private func scan(_ uiImage: UIImage) {
        isScanning = true
        ReceiptScanner().scan(image: uiImage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lines):
                    self.recognizedLines = lines
                case .failure:
                    self.recognizedLines = []
                }
                self.isScanning = false
            }
        }
    }
}

private struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var completion: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.completion(image)
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    NavigationView { ReceiptCaptureView() }
}
