//
//  UIApplication+Ext.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import SwiftUI

extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
