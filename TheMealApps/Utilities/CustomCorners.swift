//
//  CustomCorners.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import SwiftUI

struct CustomCorners: Shape {
  let corners: UIRectCorner
  let radius: CGFloat
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    
    return Path(path.cgPath)
  }
}
