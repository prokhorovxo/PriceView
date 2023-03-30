//
//  PriceView.swift
//  ticker-price
//
//  Created by Fedor Prokhorov on 30.03.2023.
//

import SwiftUI

enum PriceComponent: Identifiable {
    
    case currencySymbol(String)
    
    case number(id: String = UUID().uuidString, value: Int, isDecimal: Bool, isNew: Bool = false)
    
    case groupingSeparator(id: String = UUID().uuidString, value: String, isNew: Bool = false)
    
    case decimalSeparator(id: String = UUID().uuidString, value: String, isNew: Bool = false)
    
    var id: String {
        switch self {
        case .currencySymbol(let value):
            return "currencySymbol.\(value)"
        case .number(let id, _, _, _),
             .groupingSeparator(let id, _, _),
             .decimalSeparator(let id, _, _):
            return id
        }
    }
    
    var stringValue: String {
        switch self {
        case .currencySymbol(let value):          return value
        case .number(_, let value, _, _):         return "\(value)"
        case .groupingSeparator(_, let value, _): return value
        case .decimalSeparator(_, let value, _):  return value
        }
    }
    
    var isNew: Bool {
        switch self {
        case .currencySymbol:
            return false
            
        case .number(_, _, _, let isNew),
             .groupingSeparator(_, _, let isNew),
             .decimalSeparator(_, _, let isNew):
            return isNew
        }
    }
}

struct PriceView: View {
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.locale = .init(identifier: "en_US")
        formatter.generatesDecimalNumbers = true
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter
    }()
    
    @Binding var price: Double
    
    @State private var priceComponents: [PriceComponent]
    
    @State private var primaryColor: Color = .primary
    
    init(price: Binding<Double>) {
        self._price = price
        self.priceComponents = PriceView.makePriceComponents(from: price.wrappedValue)
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
                    
                case .number(_, let value, let isDecimal, let isNew):
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
                        .foregroundColor(isNew ? primaryColor : .primary)
                        .transition(.push(from: .top))
                    } else {
                        Text("\(value)")
                            .font(.system(size: 100.0, weight: .bold))
                            .foregroundColor(isNew ? primaryColor : .primary)
                            .transition(.push(from: .top))
                    }
                    
                case .groupingSeparator(_, let value, let isNew):
                    Text("\(value)")
                        .font(.system(size: 100.0, weight: .bold))
                        .foregroundColor(isNew ? primaryColor : .primary)
                        .transition(.identity)
                    
                case .decimalSeparator(_, let value, let isNew):
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
                    .foregroundColor(isNew ? primaryColor : .primary)
                    .transition(.identity)
                }
            }
        }
        .onChange(of: price) { newValue in
            withAnimation(.easeOut(duration: 0.25)) {
                let currentPrice = makeNumber(from: priceComponents)
                let currentPriceString = PriceView.numberFormatter.string(from: NSDecimalNumber(decimal: .init(currentPrice)))!
                let newPriceString = PriceView.numberFormatter.string(from: NSDecimalNumber(decimal: .init(newValue)))!
                
                let newPriceElements = makePriceElements(
                    from: newPriceString,
                    oldString: currentPriceString,
                    oldPirceElemets: priceComponents
                )
                priceComponents = newPriceElements
                
                primaryColor = newValue >= currentPrice ? .green : .red
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeIn) {
                        primaryColor = .primary
                    }
                }
            }
        }
    }
    
    static private func makePriceComponents(from price: Double) -> [PriceComponent] {
        let priceString = PriceView.numberFormatter.string(from: NSDecimalNumber(decimal: Decimal(price)))!
        
        var result: [PriceComponent] = []
        var isDecimalSeparatorPassed = false
        
        priceString.forEach { char in
            switch String(char) {
            case PriceView.numberFormatter.currencySymbol:
                result.append(.currencySymbol(String(char)))
                
            case PriceView.numberFormatter.groupingSeparator:
                result.append(.groupingSeparator(value: String(char)))
                
            case PriceView.numberFormatter.decimalSeparator:
                result.append(.decimalSeparator(value: String(char)))
                isDecimalSeparatorPassed = true
                
            default:
                if char.isNumber {
                    result.append(.number(value: Int(String(char))!, isDecimal: isDecimalSeparatorPassed))
                } else {
                    break
                }
            }
        }
        return result
    }
    
    private func makeNumber(from priceElements: [PriceComponent]) -> Double {
        PriceView.numberFormatter.number(from: priceElements.map { $0.stringValue }.joined())!.doubleValue
    }
    
    private func makePriceElements(from string: String, oldString: String, oldPirceElemets: [PriceComponent]) -> [PriceComponent] {
        let changedIndex = oldString.enumerated().first(where: { $0.element != string[String.Index(utf16Offset: $0.offset, in: string)] })?.offset ?? string.count - 1
        
        var result: [PriceComponent] = []
        var isLookAtSeparator: Bool = false
        
        string.enumerated().forEach { i, char in
            switch String(char) {
            case PriceView.numberFormatter.currencySymbol:
                result.append(.currencySymbol(String(char)))
                
            case PriceView.numberFormatter.groupingSeparator:
                let isNew = i >= changedIndex
                result.append(
                    .groupingSeparator(
                        id: isNew ? UUID().uuidString : oldPirceElemets[i].id,
                        value: String(char),
                        isNew: i >= changedIndex
                    )
                )
                
            case PriceView.numberFormatter.decimalSeparator:
                let isNew = i+1 >= changedIndex
                result.append(
                    .decimalSeparator(
                        id: isNew ? UUID().uuidString : oldPirceElemets[i].id,
                        value: String(char),
                        isNew: i+1 >= changedIndex
                    )
                )
                isLookAtSeparator = true
                
            default:
                if char.isNumber {
                    let isNew = i >= changedIndex
                    result.append(
                        .number(
                            id: isNew ? UUID().uuidString : oldPirceElemets[i].id,
                            value: Int(String(char))!,
                            isDecimal: isLookAtSeparator,
                            isNew: i >= changedIndex
                        )
                    )
                } else {
                    break
                }
            }
        }
        
        return result
    }
}

struct PriceView_Preview: PreviewProvider {
    
    static var previews: some View {
        PriceView(price: .constant(159.23))
    }
}
