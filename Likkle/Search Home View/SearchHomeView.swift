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
    
//    @FetchRequest(entity: Post.entity(),
//        sortDescriptors: [],
//        animation: .default)
//    private var posts: FetchedResults<Post>
    
    @ObservedObject var viewModel: SearchHomeViewModel

    var body: some View {
        NavigationView {
            VStack {
                
                CustomTextField(text: self.$viewModel.serialNumber)
                    .padding()
                    .frame(height: 20)
                
                List(self.viewModel.posts) { post in
                    NavigationLink(destination: SearchHomeDetailView(post: post)) {
                        ZStack {
                            CardView(showProfileModal: .constant(false), showAvatar: true, post: post)
                        }
                        
                    }
                }
                .listStyle(InsetListStyle())
                    .navigationBarTitle(Text("Home"), displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        ()
                    }, label: {
                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                        
                    }), trailing: Button(action: {
                        self.viewModel.showAddPostModal.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
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
                        cloudkitManager.getAccountStatus()
                        self.viewModel.getPosts()
                        }
            }
            .padding(.top)
            }
        }
    
//    func deleteAll() {
//        for post in self.viewModel.posts {
//            viewContext.delete(post)
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            // handle the Core Data error
//        }
//    }
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
    
    var post: CD_Post
    @State var showFlagAlert: Bool = false
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading) {
                
//                if !(post.postImage?.isEmpty ?? true) {
//                    Image(uiImage: UIImage(data: post.postImage!)!)
//                        .resizable()
//                        .aspectRatio(contentMode: ContentMode.fit)
//                        //.frame(height: 300, alignment: .leading)
//                }
                
                Text(post.CD_caption)
                    .padding(.leading)
                    
                
                
            }
            .alert(isPresented: $showFlagAlert, content: {
                Alert(title: Text("Report this post?"), message: Text("Does this post show nudity or encourage any racist behavior?"), dismissButton: .destructive(Text("Cancel")))
            })
            .navigationBarTitle(Text("Muckle"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.showFlagAlert.toggle()
            }, label: {
                Image(systemName: "flag.fill")
                    .foregroundColor(.red)
            }))
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

//struct FilteredList: View {
//
//    var fetchRequest: FetchRequest<Post>
//    @Binding var showProfileModal: Bool
//    var hideAvatar: Bool
//
//    init(serialNumber: String, hideAvatar: Bool, showProfileModal: Binding<Bool>) {
//        self.hideAvatar = hideAvatar
//        self._showProfileModal = showProfileModal
//        fetchRequest = FetchRequest<Post>(entity: Post.entity(), sortDescriptors: [], predicate: serialNumber.isEmpty ? NSPredicate(value: true) : NSPredicate(format: "serialNumber contains[c] %@", serialNumber), animation: .default)
//    }
//
//    var body: some View {
//            List(fetchRequest.wrappedValue, id: \.self) { post in
//                NavigationLink(destination: SearchHomeDetailView(post: post)) {
//                    ZStack {
//                        CardView(showProfileModal: self.$showProfileModal, showAvatar: hideAvatar, post: post)
//                    }
//
//                }
//
//            }
//            .listStyle(InsetListStyle())
//
//    }
//}
