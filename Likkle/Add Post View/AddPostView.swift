//
//  AddPostView.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI
import CloudKit

struct AddPostView: View {
    
    @ObservedObject var viewModel: AddPostViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                Text("Add a photo with caption to your Muckle with cash your serial code as ID")
                    .font(.footnote)
                    .padding()
                HStack {
                    Spacer()
                    if self.viewModel.images.isEmpty {
                        Image(systemName: "camera.viewfinder")
                            .resizable()
                            .frame(width: 150, height: 150, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(Color(UIColor.systemGreen))
                            .onTapGesture {
                                self.viewModel.pickerBool.toggle()
                            }
                            .padding()
                    } else {
                        Image(uiImage: self.viewModel.images[0])
                            .resizable()
                            .frame(width: 150, height: 150, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(Color(UIColor.systemGreen))
                            .cornerRadius(5)
                            .onTapGesture {
                                self.viewModel.pickerBool.toggle()
                            }
                            .padding()
                    }
                    Spacer()
                }
                
                
                
                TextField("Serial Code on cash...", text: self.$viewModel.serialNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Text("Add caption")
                    .font(.footnote)
                    .padding(.leading)
                
                TextEditor(text: self.$viewModel.caption)
                    .border(Color.gray.opacity(0.6), width: 2)
                    .cornerRadius(10)
                    .frame(height: 200)
                    .padding()
                
                Button {
                    let post = Post(context: viewContext)
                    post.serialNumber = self.viewModel.serialNumber
                    post.caption = self.viewModel.caption
                    if !self.viewModel.images.isEmpty {
                        let uploadedImage = self.viewModel.images[0]
                        
                        guard let data = uploadedImage.pngData() else {
                            self.viewModel.showAlert.toggle()
                            return  }
                    
                        post.postImage = data
                        
                    }
                    
                    do {
                        if self.viewContext.hasChanges {
                            try self.viewContext.save()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } catch {
                        self.viewModel.showAlert.toggle()
                    }
                } label: {
                    
                    Text("Share")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .accentColor(.white)
                        .padding()
                        
                }
                .disabled(!self.viewModel.images.isEmpty || !self.viewModel.caption.isEmpty && !self.viewModel.serialNumber.isEmpty ? false : true)
                .frame(width: 200, alignment: .center)
                .background(!self.viewModel.images.isEmpty || !self.viewModel.caption.isEmpty && !self.viewModel.serialNumber.isEmpty ? Color.green : Color.gray)
                .cornerRadius(20)
                .padding()

            }
            .sheet(isPresented: self.$viewModel.pickerBool, content: {
                ImagePickerView(images: self.$viewModel.images, showPicker: self.$viewModel.pickerBool, selectionLimit: 1)
            })
            .alert(isPresented: self.$viewModel.showAlert, content: {
                Alert(title: Text("Oops"), message: Text("Failed to save post.\n Please Retry"), dismissButton: .cancel(Text("OK")))
            })
            .navigationBarTitle(Text("Add Post"), displayMode: .automatic)
            .navigationBarItems(trailing:
                                    Image(systemName: "x.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25, alignment: .center)
                                    .foregroundColor(Color.red)
                                    .onTapGesture {
                                        self.presentationMode.wrappedValue.dismiss()
                                    })
            
        }
    }
}
