//
//  EditProfileView.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 1/18/21.
//

import Foundation
import Combine
import SwiftUI

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
                        Image(systemName: "camera.viewfinder")
                            .resizable()
                            .frame(width: 150, height: 150, alignment: .center)
                            .aspectRatio(contentMode: .fill)
                            .foregroundColor(Color(UIColor.systemGreen))
                            .onTapGesture {
                                self.viewModel.pickerBool.toggle()
                            }
                            .padding()
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
                    let userRecord = UserProfile(context: viewContext)
                    userRecord.username = self.viewModel.newUsername
                    userRecord.bio = self.viewModel.bioText
                    
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
