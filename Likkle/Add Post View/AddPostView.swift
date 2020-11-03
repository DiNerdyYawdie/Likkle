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
    
    var cloudkitManager: CloudKitManager
    @State var showCloudkitAlert: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                CommonInfoView(infoNotice: "Add a photo with caption to your Muckle with cash your serial code as ID")
                
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

                CommonInfoView(infoNotice: "Add caption")
                
                TextEditor(text: self.$viewModel.caption)
                    .border(Color.gray.opacity(0.6), width: 2)
                    .cornerRadius(10)
                    .frame(height: 200)
                    .padding()
                
                
                CommonButtonView(title: "Share", isDisabled: self.$viewModel.isButtonEnabled) {
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
                }

            }
            .sheet(isPresented: self.$viewModel.pickerBool, content: {
                ImagePickerView(images: self.$viewModel.images, showPicker: self.$viewModel.pickerBool, selectionLimit: 1)
            })
            .alert(isPresented: self.$viewModel.showAlert, content: {
                Alert(title: Text("Oops"), message: Text("Failed to save post.\n Please Retry"), dismissButton: .cancel(Text("OK")))
            })
            .alert(isPresented: self.$showCloudkitAlert, content: {
                Alert(title: Text("Please login to your Apple iCloud Account on your device"), message: Text("\(cloudkitManager.accountStatus.rawValue.description)"), dismissButton: .cancel())
            })
            .navigationBarTitle(Text("Add Post"), displayMode: .automatic)
            .navigationBarItems(trailing: closeButton)
            .onAppear {
                self.viewModel.enableButton()
            }
        }
        
        
    }
    
    var closeButton: some View {
        Image(systemName: "x.circle.fill")
        .resizable()
        .frame(width: 25, height: 25, alignment: .center)
        .foregroundColor(Color.red)
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}
