//
//  RowMealView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import SwiftUI
import Kingfisher

struct RowMealView: View {
  @EnvironmentObject var mealsViewModel: MealsViewModel
  @Binding var showDetailMeal: Bool
  @State private var scale: CGFloat = 1.0
  var meal: MealModel?
  
  var body: some View {
    ZStack(alignment: .bottomLeading) {
      KFImage(URL(string: "\(meal?.image ?? "")"))
        .resizable()
        .setProcessor(ResizingImageProcessor(referenceSize: CGSize(width: 100 * UIScreen.main.scale, height: 100 * UIScreen.main.scale), mode: .aspectFit))
        .loadImmediately()
        .scaledToFill()
        .scaleEffect(scale)
        .gesture(
          MagnificationGesture()
            .onChanged { value in
              scale = value
            }
            .onEnded { _ in
              scale = 1.0
            }
        )
      
      HStack {
        VStack(alignment: .leading) {
          Text(meal?.title ?? "")
            .font(.subheadline)
            .fontWeight(.semibold)
            .lineLimit(2)
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
      mealsViewModel.selectedIdDetailMeal = meal?.id ?? ""
    }
  }
}

struct RowMealView_Previews: PreviewProvider {
    static var previews: some View {
//      RowMealView(showDetailMeal: .constant(true))
      HomeView(authViewModel: AuthViewModel(), mealsViewModel: MealsViewModel())
    }
}
