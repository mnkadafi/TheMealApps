//
//  WebView.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 06/10/23.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
  let urlString: String
  
  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {
    if let range = urlString.range(of: "v=") {
      let videoID = urlString[range.upperBound...]
      
      DispatchQueue.global(qos: .background).async {
        if let url = URL(string: "https://www.youtube.com/embed/\(videoID)") {
          let request = URLRequest(url: url)
          DispatchQueue.main.async {
            uiView.load(request)
          }
        }
      }
    }
  }
}
