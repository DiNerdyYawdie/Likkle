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
    @EnvironmentObject var cloudkitManager: CloudKitManager
    
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
                
                Text(cloudkitManager.fullname)
                    .font(.title)
                
                Text(self.viewModel.bioText)
                    .lineLimit(4)
                    .padding()
                
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
                EditProfileView(viewModel: viewModel)
            })
        }
    }
}

struct ProfileList: View {
    
    var fetchRequest: FetchRequest<Post>
    var hideAvatar: Bool
    var userId: String
    @Binding var showProfileModal: Bool
    
    init(hideAvatar: Bool, showProfileModal: Binding<Bool>, userId: String) {
        self.hideAvatar = hideAvatar
        self._showProfileModal = showProfileModal
        self.userId = userId
        fetchRequest = FetchRequest<Post>(entity: Post.entity(), sortDescriptors: [], predicate: NSPredicate(format: "userId ==[c] %@", userId), animation: .default)
    }
    
    var body: some View {
            List(fetchRequest.wrappedValue, id: \.self) { post in
                NavigationLink(destination: SearchHomeDetailView(post: post)) {
                    ZStack {
                        CardView(showProfileModal: self.$showProfileModal, showAvatar: hideAvatar, post: post)
                    }
                    
                }
                
            }
            .listStyle(InsetListStyle())
            
    }
}
