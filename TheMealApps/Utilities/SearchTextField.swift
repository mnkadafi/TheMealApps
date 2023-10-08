//
//  TextFieldView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import SwiftUI

struct SearchTextField: UIViewRepresentable {
  @EnvironmentObject var authViewModel: AuthViewModel
  @EnvironmentObject var mealsViewModel: MealsViewModel
  @EnvironmentObject var favoriteViewModel: FavoritesViewModel
  @Binding var text: String
  var placeholderText: String
  var isForFavorites: Bool
  
  func makeUIView(context: Context) -> UITextField {
    let textField = UITextField(frame: .zero)
    textField.keyboardType = .default
    textField.returnKeyType = .search
    textField.font = UIFont.systemFont(ofSize: 18)
    textField.textColor = .black
    textField.attributedPlaceholder = NSAttributedString(string: "\(placeholderText)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    textField.autocapitalizationType = .none
    textField.textAlignment = .left
    textField.autoresizesSubviews = false
    textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textField.delegate = context.coordinator
    textField.autocorrectionType = .no
    textField.setLeftPaddingPoints(16)
    textField.setRightPaddingPoints(16)
  
    return textField
  }
  
  // FOR UPDATE FROM SWIFTUI TO UIKIT
  func updateUIView(_ uiView: UITextField, context: Context) {
    uiView.text = text
  }
  
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
  
  class Coordinator: NSObject, UITextFieldDelegate {
    var parent: SearchTextField
    
    init(_ textField: SearchTextField) {
      self.parent = textField
    }
    
    // FOR UPDATE FROM UIKIT TO SWIFTUI
    func textFieldDidChangeSelection(_ textField: UITextField) {
      parent.text = textField.text ?? ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      if(parent.text == "") {
        if parent.isForFavorites {
          parent.favoriteViewModel.listSearchMeals = []
          parent.favoriteViewModel.searchMode = false
        } else {
          parent.mealsViewModel.listSearchMeals = []
          parent.mealsViewModel.searchMode = false
        }
      } else {
        if parent.isForFavorites {
          parent.favoriteViewModel.textSearch = parent.text
          parent.favoriteViewModel.searchFavoriteMealByTitle(parent.authViewModel.username, mealTitle: parent.text)
        } else {
          parent.mealsViewModel.textSearch = parent.text
          parent.mealsViewModel.fetchMealsByFirstLetter(parent.text)
        }
      }
      
      UIApplication.shared.endEditing()
      return true
    }
  }
}

extension UITextField {
  func setLeftPaddingPoints(_ amount: CGFloat) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
    self.leftView = paddingView
    self.leftViewMode = .always
  }
  
  func setRightPaddingPoints(_ amount: CGFloat) {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
    self.rightView = paddingView
    self.rightViewMode = .always
  }
}
