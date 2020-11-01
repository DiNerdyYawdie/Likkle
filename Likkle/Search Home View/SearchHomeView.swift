//
//  SearchHomeView.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import SwiftUI
import CoreData

struct SearchHomeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest( entity: Post.entity(),
        sortDescriptors: [],
        animation: .default)
    private var posts: FetchedResults<Post>
    var cloudKitManager: CloudKitManager
    
    @ObservedObject var viewModel: SearchHomeViewModel

    var body: some View {
        NavigationView {
            VStack {
                HomeTextField(viewModel: self.viewModel)
                
                FilteredList(serialNumber: self.viewModel.serialNumber)
                    .navigationBarTitle(Text("Home"), displayMode: .automatic)
                    .navigationBarItems(trailing: Button(action: {
                        self.viewModel.showAddPostModal.toggle()
                    }, label: {
                        Text("Add Post")
                    }))
                    .sheet(isPresented: self.$viewModel.showAddPostModal, content: {
                        AddPostView(viewModel: AddPostViewModel(), cloudkitManager: cloudKitManager)
                    })
                    .alert(isPresented: self.$viewModel.showAlert, content: {
                        Alert(title: Text("Oops"), message: Text("Failed to save post.\n Please Retry"), dismissButton: .cancel(Text("OK")))
                    })
                    .onAppear {
                        cloudKitManager.requestUserInfo()
                        }
                }
            }
        }
}

struct HomeTextField: View {
    
    @ObservedObject var viewModel: SearchHomeViewModel
    
    var body: some View {
        
        HStack {
            TextField("Serial Code on Cash...", text: self.$viewModel.serialNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading)
            
            Button(action: { () },
                   label: {
                Text("Sort")
                    .fontWeight(.semibold)
                    .foregroundColor(Color(UIColor.systemGreen))
                   })
                .padding(.trailing)
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
        VStack(alignment: .leading) {
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 350, height: 350, alignment: .center)
                .padding()
            
            Text(post.caption ?? "")
                .padding(.leading)
            
            List {
                
                CommentRowView()
            }
            
            
        }
        .navigationBarTitle(Text(post.serialNumber ?? ""))
        
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
    
    init(serialNumber: String) {
        fetchRequest = FetchRequest<Post>(entity: Post.entity(), sortDescriptors: [], predicate: serialNumber.isEmpty ? NSPredicate(value: true) : NSPredicate(format: "serialNumber contains[c] %@", serialNumber), animation: .default)
    }
    
    var body: some View {
            List(fetchRequest.wrappedValue, id: \.self) { post in
                NavigationLink(destination: SearchHomeDetailView(post: post)) {
                    CardView(post: post)
                        .padding(.trailing)
                }
                
            }
            .listStyle(InsetListStyle())
    }
}
