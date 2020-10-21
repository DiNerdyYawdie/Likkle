//
//  SearchHomeViewModel.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import Foundation
import Combine

class SearchHomeViewModel: ObservableObject {
    
    @Published var serialNumber: String  = ""
    @Published var showAddPostModal: Bool = false
    @Published var showAlert: Bool = false
}
