//
//  EditProfileView.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 1/18/21.
//

import Foundation
import Combine
import SwiftUI
import CloudKit

struct EditProfileView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cloudkitManager: CloudKitManager
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Add Photo")) {
                        if self.viewModel.images.isEmpty {
                            Image(systemName: "camera.viewfinder")
                                .resizable()
                                .frame(width: 150, height: 150, alignment: .center)
                                .aspectRatio(contentMode: .fill)
                                .foregroundColor(Color(UIColor.systemGreen))
                                .padding()
                                .onTapGesture {
                                    self.viewModel.pickerBool.toggle()
                                }
                        } else {
                            Image(uiImage: self.viewModel.images[0])
                                .resizable()
                                .frame(width: 150, height: 150, alignment: .center)
                                .aspectRatio(contentMode: .fill)
                                .foregroundColor(Color(UIColor.systemGreen))
                                .padding()
                                .onTapGesture {
                                    self.viewModel.pickerBool.toggle()
                                }
                        }
                    }
                    
                    Section(header: Text("Change Username")) {
                        TextField("Change your username", text: self.$viewModel.newUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.leading)
                    }
        
                    Section(header: Text("Change Bio")) {
                        TextEditor(text: self.$viewModel.bioText)
                            .frame(height: 200, alignment: .center)
                    }
                }
                CommonButtonView(title: "Save", isDisabled: .constant(false)) {
                    let usersRecord = CKRecord(recordType: "Users")
                    if !self.viewModel.images.isEmpty {
                        let uploadedImage = self.viewModel.images[0]
                        
                        guard let data = uploadedImage.pngData() else {
                            self.viewModel.showAlert.toggle()
                            return  }
                        
                        
                        cloudkitManager.editUserInfo(name: self.viewModel.newUsername, bio: self.viewModel.bioText, data: data) {
                            DispatchQueue.main.async {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                          }
                    } else {
                        cloudkitManager.editUserInfo(name: self.viewModel.newUsername, bio: self.viewModel.bioText, data: nil) {
                        DispatchQueue.main.async {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                      }
                    }
                }
            }
            .navigationTitle(Text("Edit Profile"))
            .navigationBarItems(trailing: closeButton)
            .sheet(isPresented: self.$viewModel.pickerBool, content: {
                ImagePickerView(images: self.$viewModel.images, showPicker: self.$viewModel.pickerBool, selectionLimit: 1)
            })
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
