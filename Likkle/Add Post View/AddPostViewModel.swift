//
//  AddPostViewModel.swift
//  Likkle
//
//  Created by Chad-Michael Muirhead on 10/3/20.
//

import Foundation
import Combine
import UIKit

class AddPostViewModel: ObservableObject {
    
    @Published var serialNumber: String  = ""
    @Published var caption: String = ""
    
    @Published var isButtonEnabled: Bool = false
    @Published var pickerBool: Bool = false
    @Published var showAlert: Bool = false
    @Published var images: [UIImage] = []
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    func enableButton() {
        Publishers.CombineLatest3($images, $caption, $serialNumber)
            .receive(on: RunLoop.main)
            .map { !$0.isEmpty && $2.isEmpty || $1.isEmpty && $2.isEmpty }
            .assign(to: &$isButtonEnabled)
            
            
    }
}
