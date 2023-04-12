//
//  PriceView.swift
//  ticker-price
//
//  Created by Fedor Prokhorov on 30.03.2023.
//

import SwiftUI

struct PriceView: View {
    
    @Binding var price: Double
    
    @State private var priceComponents: [PriceComponent]
    
    @State private var highlightedColor: Color = .primary
    
    init(price: Binding<Double>) {
        self._price = price
        self.priceComponents = PriceComponent.createPriceComponents(from: price.wrappedValue,
                                                                    usingFormatter: .usNumberFormatter)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: .zero) {
            ForEach(priceComponents, id: \.id) {
                switch $0 {
                case .currencySymbol(let value):
                    Text(
                        AttributedString(
                            value,
                            attributes: AttributeContainer(
                                [
                                    .font: UIFont.systemFont(ofSize: 50.0, weight: .bold),
                                    .baselineOffset: 15
                                ]
                            )
                        )
                    )
                    
                case .number(_, let value, let isDecimal, let isHighlighted):
                    if isDecimal {
                        Text(
                            AttributedString(
                                "\(value)",
                                attributes: AttributeContainer(
                                    [
                                        .font: UIFont.systemFont(ofSize: 50.0, weight: .bold),
                                        .baselineOffset: 12
                                    ]
                                )
                            )
                        )
                        .foregroundColor(isHighlighted ? highlightedColor : .primary)
                        .transition(.push(from: .top))
                    } else {
                        Text("\(value)")
                            .font(.system(size: 100.0, weight: .bold))
                            .foregroundColor(isHighlighted ? highlightedColor : .primary)
                            .transition(.push(from: .top))
                    }
                    
                case .groupingSeparator(_, let value, let isHighlighted):
                    Text("\(value)")
                        .font(.system(size: 100.0, weight: .bold))
                        .foregroundColor(isHighlighted ? highlightedColor : .primary)
                        .transition(.identity)
                    
                case .decimalSeparator(_, let value, let isHighlighted):
                    Text(
                        AttributedString(
                            value,
                            attributes: AttributeContainer(
                                [
                                    .font: UIFont.systemFont(ofSize: 50.0, weight: .bold),
                                    .baselineOffset: 12
                                ]
                            )
                        )
                    )
                    .foregroundColor(isHighlighted ? highlightedColor : .primary)
                    .transition(.identity)
                }
            }
        }
        .onChange(of: price) { newPrice in
            withAnimation(.easeOut(duration: 0.25)) {
                let oldPrice = PriceComponent.createPrice(from: priceComponents, usingFormatter: .usNumberFormatter)
                let newPriceComponents = PriceComponent.createPriceComponents(oldPriceComponents: priceComponents,
                                                                              newPrice: newPrice,
                                                                              usingFormatter: .usNumberFormatter)

                priceComponents = newPriceComponents
                highlightedColor = newPrice == oldPrice ? .primary : (newPrice > oldPrice ? .green : .red)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeIn) {
                        highlightedColor = .primary
                    }
                }
            }
        }
    }
}

struct PriceView_Preview: PreviewProvider {
    
    static var previews: some View {
        PriceView(price: .constant(159.23))
    }
}
