//
//  ContentView.swift
//  PriceView
//
//  Created by Fedor Prokhorov on 12.04.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var price: Double = 159.95
    
    private let incrementValue = 0.5
    
    var body: some View {
        VStack(alignment: .center, spacing: 25.0) {
            Spacer()
            PriceView(price: $price)
                .clipped()
            Spacer()
            Button {
                price = Double.random(in: (price - incrementValue)...(price + incrementValue))
            } label: {
                Text("Update price")
                    .font(.system(size: 17.0, weight: .semibold))
                    .frame(height: 44.0)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentColor)
            .cornerRadius(22.0)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
