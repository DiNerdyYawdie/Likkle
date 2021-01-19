//
//  SearchHomeView.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI
import CoreData
import UIKit

struct SearchHomeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var cloudkitManager: CloudKitManager
    
    @FetchRequest( entity: Post.entity(),
        sortDescriptors: [],
        animation: .default)
    private var posts: FetchedResults<Post>
    
    @ObservedObject var viewModel: SearchHomeViewModel

    var body: some View {
        NavigationView {
            VStack {
                HomeTextField(viewModel: self.viewModel)
                
                FilteredList(serialNumber: self.viewModel.serialNumber, hideAvatar: false, showProfileModal: self.$viewModel.showProfileModal)
                    .navigationBarTitle(Text("Home"), displayMode: .automatic)
                    .navigationBarItems(trailing: Button(action: {
                        self.viewModel.showAddPostModal.toggle()
                    }, label: {
                        Text("Add Post")
                            .fontWeight(.bold)
                    }))
                    .sheet(isPresented: self.$viewModel.showProfileModal, content: {
                        ProfileView(viewModel: ProfileViewModel())
                    })
                    .sheet(isPresented: self.$viewModel.showAddPostModal, content: {
                        AddPostView(viewModel: AddPostViewModel())
                            .environmentObject(cloudkitManager)
                    })
                    .alert(isPresented: self.$viewModel.showAlert, content: {
                        Alert(title: Text("Oops"), message: Text("Failed to save post.\n Please Retry"), dismissButton: .cancel(Text("OK")))
                    })
                    .onAppear {
                        //deleteAll()
                        cloudkitManager.requestUserInfo()
                        }
            }
            }
        }
    
    func deleteAll() {
        for post in posts {
            viewContext.delete(post)
        }
        do {
            try viewContext.save()
        } catch {
            // handle the Core Data error
        }
    }
}

struct HomeTextField: View {
    
    @ObservedObject var viewModel: SearchHomeViewModel
    
    var body: some View {
        
        HStack {
            CustomTextField(text: self.$viewModel.serialNumber)
                .padding()
                .frame(height: 20)
//            TextField("Serial Code on Cash...", text: self.$viewModel.serialNumber)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding(.horizontal)
        }
    }
}

struct SearchHomeRowView: View {
    
    var post: Post
    
    var body: some View {
        VStack {
            Text(post.serialNumber ?? "Wow")
                .padding()
        }
        .cornerRadius(20)
        .background(Color.white)
    }
}

struct SearchHomeDetailView: View {
    
    var post: Post
    
    var body: some View {
        
        ScrollView {
        VStack(alignment: .leading) {
            
            if !(post.postImage?.isEmpty ?? true) {
                Image(uiImage: UIImage(data: post.postImage!)!)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fit)
                    //.frame(height: 300, alignment: .leading)
            }
            
            Text(post.caption ?? "")
                .padding(.leading)
                
            
            
        }
        .navigationBarTitle(Text("Muckle"), displayMode: .inline)
        }
    }
}


struct CommentRowView: View {
    
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "person.circle")
                .padding()
            
                Text("first comment going in it")
                    .font(.caption)
                    .padding()
        }
    }
}

struct FilteredList: View {
    
    var fetchRequest: FetchRequest<Post>
    @Binding var showProfileModal: Bool
    var hideAvatar: Bool
    
    init(serialNumber: String, hideAvatar: Bool, showProfileModal: Binding<Bool>) {
        self.hideAvatar = hideAvatar
        self._showProfileModal = showProfileModal
        fetchRequest = FetchRequest<Post>(entity: Post.entity(), sortDescriptors: [], predicate: serialNumber.isEmpty ? NSPredicate(value: true) : NSPredicate(format: "serialNumber contains[c] %@", serialNumber), animation: .default)
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
