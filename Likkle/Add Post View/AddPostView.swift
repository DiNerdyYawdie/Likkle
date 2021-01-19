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
    @EnvironmentObject var cloudkitManager: CloudKitManager

    @State var showCloudkitAlert: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                Text("Add a photo with caption to your Muckle with cash your serial code as ID")
                    .font(.footnote)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
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
                    .padding(.horizontal)
                
                
                TextEditor(text: self.$viewModel.caption)
                    .border(Color.gray.opacity(0.6), width: 2)
                    .cornerRadius(10)
                    .frame(height: 200)
                    .padding()

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
            .navigationBarItems(trailing: shareButton)
            .onAppear {
                self.viewModel.enableButton()
            }
        }
        
        
    }
    
    var shareButton: some View {
        Text("Share")
            .fontWeight(.bold)
            .foregroundColor(!self.viewModel.serialNumber.isEmpty ? Color(UIColor.systemGreen) : .gray)
            .disabled(!self.viewModel.serialNumber.isEmpty ? false : true)
            .onTapGesture {
            let post = Post(context: viewContext)
            
            post.serialNumber = self.viewModel.serialNumber
            post.caption = self.viewModel.caption
            
            post.userId = cloudkitManager.userRecord?.recordID.recordName
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
}
