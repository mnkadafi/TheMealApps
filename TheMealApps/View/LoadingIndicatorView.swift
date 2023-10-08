//
//  LoadingIndicatorView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import SwiftUI

struct LoadingIndicatorView: View {
  var body: some View {
    VStack {
      Text("Loading...")
      ActivityIndicator(isAnimating: .constant(true), style: .large, color: .gray)
    }
    .frame(width: 120,
           height: 120)
    .background(Color(.init(white: 0.95, alpha: 1)))
    .foregroundColor(Color.primary)
    .cornerRadius(20)
  }
}
