import SwiftUI
import ReceiptScanner
import ExpenseStore
import SwiftData

struct ReceiptCaptureView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    private let persistence: PersistenceController

    @State private var showPicker = false
    @State private var image: UIImage?
    @State private var recognizedLines: [String] = []
    @State private var isScanning = false
    @State private var pickerSource: UIImagePickerController.SourceType = .camera
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var date = Date()
    @State private var category: String = ""

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

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
            Form {
                if !recognizedLines.isEmpty {
                    Section(header: Text("Lines")) {
                        ForEach(recognizedLines.indices, id: \.self) { index in
                            TextField("Line", text: Binding(
                                get: { recognizedLines[index] },
                                set: { recognizedLines[index] = $0 }
                            ))
                        }
                    }
                    Section(header: Text("Details")) {
                        TextField("Title", text: $title)
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        TextField("Category", text: $category)
                        Button("Save") { save() }
                    }
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
                case .success(let data):
                    self.recognizedLines = data.lines
                    self.title = data.vendor ?? ""
                    if let total = data.total { self.amount = String(total) }
                    self.date = data.date ?? Date()
                case .failure:
                    self.recognizedLines = []
                }
                self.isScanning = false
            }
        }
    }

    private func save() {
        guard let amt = Double(amount) else { return }
        do {
            let exp = Expense(title: title, amount: amt, date: date, category: category.isEmpty ? nil : category)
            context.insert(exp)
            try context.save()
            dismiss()
        } catch {
            print("Save error: \(error)")
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
    let controller = PersistenceController(inMemory: true)
    let ctx = controller.container.viewContext
    return NavigationView { ReceiptCaptureView(persistence: controller) }
        .environment(\.modelContext, ctx)
}
