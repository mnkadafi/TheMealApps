//
//  RowFavoritesView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import SwiftUI
import Kingfisher

struct RowFavoritesView: View {
  @EnvironmentObject var favoritesViewModel: FavoritesViewModel
  @Binding var showDetailMeal: Bool
  var meal: FavoriteModel?
  
  var body: some View {
    ZStack(alignment: .bottomLeading) {
      KFImage(URL(string: "\(meal?.image ?? "")"))
        .resizable()
        .setProcessor(ResizingImageProcessor(referenceSize: CGSize(width: 100 * UIScreen.main.scale, height: 100 * UIScreen.main.scale), mode: .aspectFit))
        .loadImmediately()
        .scaledToFill()
        .frame(height: 250)
      
      HStack {
        VStack(alignment: .leading) {
          Text(meal?.title ?? "")
            .font(.subheadline)
            .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        
        Spacer()
      }
      .padding()
      .background(Color.gray.opacity(0.5))
    }
    .background(Color(.init(white: 0.95, alpha: 1)))
    .cornerRadius(6)
    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
    .onTapGesture {
      showDetailMeal.toggle()
      favoritesViewModel.selectedIdDetailMeal = meal?.id ?? ""
    }
  }
}

struct RowFavoritesView_Previews: PreviewProvider {
  static var previews: some View {
    RowFavoritesView(showDetailMeal: .constant(true))
  }
}
