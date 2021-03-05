//
//  CommonViews.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI
import PhotosUI
import SDWebImage
import UIKit

struct CardView: View {
    
    @Binding var showProfileModal: Bool
    var showAvatar: Bool
    var post: CD_Post
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if !showAvatar {
                AvatarView()
                    .onTapGesture {
                        self.showProfileModal.toggle()
                    }
            }
            
           
//            if !(post.postImage?.isEmpty ?? true) {
//                Image(uiImage: UIImage(data: post.postImage!)!)
//                    .resizable()
//                    .aspectRatio(contentMode: ContentMode.fit)
//                    .cornerRadius(10)
//                EmptyView()
//            }

 
            HStack {
                VStack(alignment: .leading) {
                    Text(post.CD_serialNumber ?? "serial number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(post.CD_caption ?? "caption")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
            }
            .padding()
        }
    }
}

struct AvatarView: View {
    
    var body: some View {
        HStack {
            Image(systemName: "person")
                .clipShape(Circle())
                .shadow(radius: 10)
                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                .frame(width: 25, height: 25, alignment: .center)
            
            Text("Chad-Michael")
                .font(.caption2)
        }
        
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    
    @Binding var images: [UIImage]
    @Binding var showPicker: Bool
    var selectionLimit: Int
    
    func makeUIViewController(context: Context) -> some UIViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        //images.removeAll()
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        var parent: ImagePickerView
        
        init(parent: ImagePickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            parent.showPicker.toggle()
            
            for img in results {
                if img.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    img.itemProvider.loadObject(ofClass: UIImage.self) { (image, err) in
                        guard let image1 = image else {return}
                        
                        DispatchQueue.main.async {
                            self.parent.images.append(image1 as! UIImage)
                        }
                    }
                } else {
                    //Handle Error
                    parent.showPicker.toggle()
                }
            }
        }
    }
}

struct CommonButtonView: View {
    
    var title: String
    @Binding var isDisabled: Bool
    var buttonTapped: () -> Void
    
    var body: some View {
        
        Button(action: {
            self.buttonTapped()
        }, label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .accentColor(.white)
                .padding()
        })
        .disabled(isDisabled)
        .frame(width: 300, alignment: .center)
        .background(isDisabled ? Color.gray : Color.green)
        .cornerRadius(20)
        .padding()
        
    }
}

struct TextView: UIViewRepresentable {

@Binding var text: String
var placeholderText: String
var textStyle: UIFont.TextStyle

func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()

    textView.font = UIFont.preferredFont(forTextStyle: textStyle)
    textView.autocapitalizationType = .sentences
    textView.isSelectable = true
    textView.isUserInteractionEnabled = true
    textView.delegate = context.coordinator
    textView.layer.borderWidth = 0.6
    textView.layer.borderColor = UIColor.lightGray.cgColor
    textView.layer.cornerRadius = 10
    textView.text = placeholderText
    textView.textColor = UIColor.lightGray
    return textView
}

func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
    uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
}

func makeCoordinator() -> Coordinator {
    Coordinator(self)
}
 
class Coordinator: NSObject, UITextViewDelegate {
    var parent: TextView
 
    init(_ parent: TextView) {
        self.parent = parent
    }
 
    func textViewDidChange(_ textView: UITextView) {
        self.parent.text = textView.text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.parent.placeholderText
            textView.textColor = UIColor.lightGray
        }
    }
}}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct CustomTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }

    @Binding var text: String
    var isFirstResponder: Bool = false

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField()
        textField.placeholder = "Serial number on your cash "
        textField.rightViewMode = .always
        textField.borderStyle = .roundedRect
        let leftViewImage = UIImageView(frame: CGRect(x: 5, y: 0, width: 10, height: 10))
        let rightViewImage = UIImageView(frame: CGRect(x: 5, y: 0, width: 10, height: 10))
        
        let magnifyingglassImage = UIImage(systemName: "magnifyingglass")
        let micImage = UIImage(systemName: "mic.fill")
        
        leftViewImage.image = magnifyingglassImage
        rightViewImage.image = micImage
        textField.leftView = leftViewImage
        textField.rightView = rightViewImage
        textField.leftViewMode = .always
        
        textField.delegate = context.coordinator
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}
