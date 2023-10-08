//
//  LoginView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 05/10/23.
//

import SwiftUI

struct LoginView: View {
  @ObservedObject var authViewModel: AuthViewModel
  @State private var isLoginMode: Bool = true
  @State private var username: String = ""
  @State private var password: String = ""
  @State private var confirmPassword: String = ""
  @State private var selectedImage: UIImage?
  
  var body: some View {
    ScrollView {
      ZStack {
        VStack(spacing: 16) {
          Picker(selection: $isLoginMode) {
            Text("Login")
              .tag(true)
            Text("Create Account")
              .tag(false)
          } label: {
            Text("Picker Here")
          }
          .pickerStyle(SegmentedPickerStyle())
          
          Group {
            TextField("Username", text: $username)
              .keyboardType(.default)
              .autocapitalization(.none)
              .autocorrectionDisabled(true)
            
            SecureField("Password", text: $password)
              .keyboardType(.default)
            
            if !isLoginMode {
              SecureField("Confirm Password", text: $confirmPassword)
                .keyboardType(.default)
            }
          }
          .padding(12)
          .background(Color.white)
          
          Button {
            handleAction()
          } label: {
            HStack {
              Spacer()
              if authViewModel.isLoading {
                ActivityIndicator(isAnimating: .constant(true), style: .medium, color: .white)
                  .padding(.vertical, 12)
              } else {
                Text(isLoginMode ? "Login" : "Create Account")
                  .foregroundColor(Color.white)
                  .padding(.vertical, 12)
                  .font(.system(size: 14, weight: .semibold))
              }
              Spacer()
            }
            .background(Color.blue)
            .cornerRadius(6)
          }
          .padding(.top)
          .alert(isPresented: $authViewModel.showAlertMessage) {
            Alert(
              title: Text("Information"),
              message: Text(authViewModel.messageAction)
            )
          }
          
        }
        .padding()
      }
    }
    .navigationBarTitle(isLoginMode ? "Login" : "Create Account")
    .background(Color(.init(white: 0, alpha: 0.05)).edgesIgnoringSafeArea(.all))
  }
  
  private func handleAction() {
    if isLoginMode {
      authViewModel.signInAccount(username: username, password: password)
    } else {
      if password != confirmPassword {
        authViewModel.messageAction = "Password and Confirm Password is not the same, try again."
        authViewModel.showAlertMessage.toggle()
      } else {
        authViewModel.createNewAccount(username: username, password: password)
      }
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(authViewModel: AuthViewModel())
  }
}
