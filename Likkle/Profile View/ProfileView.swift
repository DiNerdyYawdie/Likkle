//
//  ProfileView.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/21/20.
//

import SwiftUI
import CloudKit

struct ProfileView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @State private var profileSegmentIndex = 0
    var cloudKitManager: CloudKitManager
    @FetchRequest(
        entity: Post.entity(),
        sortDescriptors: []
    ) var posts: FetchedResults<Post>
    
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 100, height: 100, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                Text(cloudKitManager.fullname)
                    .font(.title)
                
                TextView(text: self.$viewModel.bioText, placeholderText: "Tell us about yourself?", textStyle: UIFont.TextStyle.caption1)
                    .padding()
                    .frame(height: 100)
                
                Picker(selection: self.$profileSegmentIndex, label: Text("Jahkno")) {
                    Text("My Posts").tag(0)
                    
                    Text("Favorites").tag(1)
                }
                
                .onTapGesture {
                    if self.profileSegmentIndex == 0 {
                        self.profileSegmentIndex = 1
                    } else {
                        self.profileSegmentIndex = 0
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                FilteredList(serialNumber: "", hideAvatar: profileSegmentIndex == 0 ? true : false, showProfileModal: .constant(false))
            }
            .onTapGesture {
                self.hideKeyboard()
            }
            .navigationBarTitle(Text("Profile"))
            .navigationBarItems(trailing: Button(action: {
                self.viewModel.showAddPostModal.toggle()
            }, label: {
                Text("Edit Profile")
            }))
            .sheet(isPresented: self.$viewModel.showAddPostModal, content: {
                EditProfileView(viewModel: viewModel, cloudkitManager: cloudKitManager)
            })
        }
    }
}

struct EditProfileView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    var cloudkitManager: CloudKitManager
    
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
