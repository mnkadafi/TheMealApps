//
//  UIGrid.swift
//  TheMealApps
//
//  Created by Mochamad Nurkhayal Kadafi on 08/10/23.
//

import SwiftUI

struct UIGridView<Content: View, T: Hashable>: View {
  private let columns: Int
  
  // Multi-dimensional array of your list. Modified as per rendering needs.
  private var list: [[T]] = []
  
  // This block you specify in 'UIGrid' is stored here
  private let content: (T) -> Content
  
  init(columns: Int, list: [T], @ViewBuilder content:@escaping (T) -> Content) {
    self.columns = columns
    self.content = content
    self.setupList(list)
  }
  
  // setupList(_:) Converts your array into multi-dimensional array.
  private mutating func setupList(_ list: [T]) {
    var column = 0
    var columnIndex = 0
    
    for object in list {
      if columnIndex < self.columns {
        if columnIndex == 0 {
          self.list.insert([object], at: column)
          columnIndex += 1
        }else {
          self.list[column].append(object)
          columnIndex += 1
        }
      }else {
        column += 1
        self.list.insert([object], at: column)
        columnIndex = 1
      }
    }
  }
  
  var body: some View {
    VStack {
      ForEach(0 ..< self.list.count, id: \.self) { i  in
        HStack {
          ForEach(self.list[i], id: \.self) { object in
            
            // Your UI defined in the block is called from here.
            self.content(object)
//              .frame(width: UIScreen.main.bounds.size.width/CGFloat(self.columns))
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
      }
      
    }
  }
}
