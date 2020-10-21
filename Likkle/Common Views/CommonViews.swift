//
//  CommonViews.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI
import PhotosUI
import SDWebImage

struct CardView: View {
    
    var post: Post
    
    var body: some View {
        VStack {
//            if !post.postImage!.isEmpty {
//                Image(uiImage: UIImage(data: post.postImage!)!)
//                    .resizable()
//                    .aspectRatio(contentMode: ContentMode.fill)
//                    .frame(height: 300)
//            }

 
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
        .frame(width: 200, alignment: .center)
        .background(isDisabled ? Color.gray : Color.green)
        .cornerRadius(20)
        .padding()
        
    }
}
