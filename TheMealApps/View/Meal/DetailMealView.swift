//
//  DetailMealView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import SwiftUI
import Kingfisher

struct DetailMealView: View {
  @Environment(\.presentationMode) var mode: Binding<PresentationMode>
  @EnvironmentObject var authViewModel: AuthViewModel
  @ObservedObject var detailMealViewModel = DetailMealViewModel()
  @Binding var showDetailMeal: Bool
  
  @State private var isZoomed: Bool = false
  @State private var scale: CGFloat = 1.0
  @State private var expandImage: Bool = false
  @State private var activeHeroAnimation: Bool = false
  @State private var newHeight: CGFloat = 0.0
  private let maxHeight = round(UIScreen.main.bounds.height / 2.045)
  var mealID: String
  
  var body: some View {
    ScrollView(axes, showsIndicators: false) {
      VStack {
        if detailMealViewModel.isLoading {
          HStack {
            Spacer()
            LoadingIndicatorView()
            Spacer()
          }
          .frame(height: maxHeight)
        } else {
          GeometryReader { proxy in
            ZStack {
              KFImage(URL(string: detailMealViewModel.detailMeal?.image ?? ""))
                .onSuccess { result in
                  DispatchQueue.main.async {
                    let size = result.image.size
                    let tupleSize = (size.width, size.height)
                    let (x, y) = tupleSize
                    let intWidth = CGFloat(x)
                    let intHeight = CGFloat(y)

                    let ratio = intWidth / intHeight
                    newHeight = proxy.size.width / ratio
                  }
                }
                .resizable()
                .loadImmediately()
                .scaledToFit()
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                .onTapGesture {
                  withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                    expandImage.toggle()
                    activeHeroAnimation.toggle()
                    
                    scale = 1.0
                  }
                }
                .scaleEffect(scale)
                .gesture(
                  MagnificationGesture()
                    .onChanged { value in
                      scale = value
                    }
                    .onEnded { _ in
                      if !expandImage {
                        scale = 1.0
                      }
                    }
                )
            }
            .offset(y: expandImage ? (proxy.size.height - newHeight) / 2 : 0)
            .frame(maxWidth: .infinity)
          }
          .frame(height: expandImage ? UIScreen.main.bounds.height : newHeight)
          
          if scale == 1.0 {
            VStack(alignment: .leading, spacing: 16) {
              sectionOneInformation
              
              Divider()
              
              sectionTwoInformation
              
              Divider()
              
              sectionThreeInformation
              
              Divider()
              
              sectionFourInformation
            }
            .padding(.horizontal)
          }
        }
      }
    }
    .background(Color(.init(white: 0.95, alpha: 1)))
    .edgesIgnoringSafeArea(.all)
    .overlay(
      backBarButton, alignment: .topLeading
    )
    .onAppear {
      detailMealViewModel.fetchMealsById(authViewModel.username, mealID)
    }
  }
  
  private var sectionOneInformation: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading, spacing: 8) {
        Text(detailMealViewModel.detailMeal?.title ?? "")
          .font(.title.weight(.semibold))
        
        Text("Category: \(detailMealViewModel.detailMeal?.category ?? "")")
          .font(.system(size: 20))
          .foregroundColor(.secondary)
        
        Text("Area: \(detailMealViewModel.detailMeal?.area ?? "")")
          .font(.system(size: 20))
          .foregroundColor(.secondary)
      }
      
      Spacer(minLength: 5)
      
      if detailMealViewModel.detailMeal != nil {
        Button {
          if detailMealViewModel.isFavorite {
            detailMealViewModel.deleteFavoriteMeal(authViewModel.username, detailMealViewModel.detailMeal!)
          } else {
            detailMealViewModel.addFavoriteMeal(authViewModel.username, detailMealViewModel.detailMeal!)
          }

          detailMealViewModel.showAlertMessage.toggle()
        } label: {
          Image(systemName: self.detailMealViewModel.isFavorite ? "heart.fill" : "heart")
            .font(.largeTitle)
        }
        .alert(isPresented: $detailMealViewModel.showAlertMessage) {
          Alert(
            title: Text("Information"),
            message: Text(detailMealViewModel.messageAction)
          )
        }
      }
    }
    .padding(.vertical)
  }
  
  private var sectionTwoInformation: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Instructions")
        .font(.body.weight(.semibold))
      
      Text(detailMealViewModel.detailMeal?.instructions ?? "")
    }
  }
  
  private var sectionThreeInformation: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Video Youtube")
        .font(.body.weight(.semibold))
      
      WebView(urlString: detailMealViewModel.detailMeal?.youtube ?? "")
        .frame(height: 300)
        .cornerRadius(8)
    }
  }
  
  private var sectionFourInformation: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Ingredient")
        .font(.body.weight(.semibold))
      
      ForEach(detailMealViewModel.detailMeal?.ingredientsAndMeasure?.map { (key: $0, value: $1) } ?? [], id: \.key) { ingredientAndMeasure in
        HStack {
          Text("\(ingredientAndMeasure.key):")
          Spacer()
          Text("\(ingredientAndMeasure.value)")
        }
        Divider()
      }
    }
    .padding(.bottom, 50)
  }
  
  private var backBarButton: some View {
    Button(action: {
      self.showDetailMeal.toggle()
    }, label: {
      Image(systemName: "xmark")
        .font(.headline)
        .padding(16)
        .background(Color.white)
        .cornerRadius(10)
        .padding()
        .foregroundColor(.primary)
    })
    .disabled(expandImage ? true : false)
    .opacity(expandImage ? 0 : 1)
  }
  
  private var axes: Axis.Set {
    return expandImage ? [] : .vertical
  }
}

struct DetailMealView_Previews: PreviewProvider {
  static var previews: some View {
    DetailMealView(showDetailMeal: .constant(true), mealID: "52772")
      .environmentObject(AuthViewModel())
  }
}
