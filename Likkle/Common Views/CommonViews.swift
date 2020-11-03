//
//  CommonViews.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI
import PhotosUI
import SDWebImage

struct CommonInfoView: View {
    
    var infoNotice: String
    
    var body: some View {
        VStack {
            Text(infoNotice)
                .font(.footnote)
                .padding()
        }
        .cornerRadius(10)
        .border(Color.white, width: 1)
        .background(Color(UIColor.gray))
    }
}

struct CardView: View {
    
    @Binding var showProfileModal: Bool
    var showAvatar: Bool
    var post: Post
    
    var body: some View {
        VStack(alignment: .leading) {
            
            if showAvatar {
                AvatarView()
                    .onTapGesture {
                        self.showProfileModal.toggle()
                    }
            }
            
           
            if !(post.postImage?.isEmpty ?? true) {
                Image(uiImage: UIImage(data: post.postImage!)!)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(height: 300)
            }

 
            HStack {
                VStack(alignment: .leading) {
                    Text(post.serialNumber ?? "serial number")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
                    Text(post.caption ?? "caption")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                        .lineLimit(3)
                    
                    Text("Hmm")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .layoutPriority(100)
 
                Spacer()
            }
            .padding()
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .padding([.top])
    }
}

struct AvatarView: View {
    
    var body: some View {
        
        Image(systemName: "person")
            .clipShape(Circle())
            .shadow(radius: 10)
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
            .frame(width: 20, height: 20, alignment: .center)
            .padding()
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
