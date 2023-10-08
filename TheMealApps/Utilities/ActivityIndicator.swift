//
//  ActivityIndicator.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
  
  @Binding var isAnimating: Bool
  let style: UIActivityIndicatorView.Style
  let color: UIColor
  
  func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
    let indicatorView = UIActivityIndicatorView(style: style)
    indicatorView.color = color
    return indicatorView
  }
  
  func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
    isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
  }
}
