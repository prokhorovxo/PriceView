//
//  PriceComponent.swift
//  ticker-price
//
//  Created by Fedor Prokhorov on 30.03.2023.
//

import Foundation

enum PriceComponent: Identifiable {
    
    case currencySymbol(String)
    
    case number(id: String = UUID().uuidString,
                value: Int,
                isDecimal: Bool,
                isHighlighted: Bool = false)
    
    case groupingSeparator(id: String = UUID().uuidString,
                           value: String,
                           isHighlighted: Bool = false)
    
    case decimalSeparator(id: String = UUID().uuidString,
                          value: String,
                          isHighlighted: Bool = false)
    
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
    
    var isHighlighted: Bool {
        switch self {
        case .currencySymbol:
            return false
            
        case .number(_, _, _, let isHighlighted),
             .groupingSeparator(_, _, let isHighlighted),
             .decimalSeparator(_, _, let isHighlighted):
            return isHighlighted
        }
    }
}

// MARK: - Price components factory

extension PriceComponent {
    
    static func createPriceComponents(from price: Double,
                                      usingFormatter numberFormatter: NumberFormatter) -> [PriceComponent] {
        
        let decimalPrice = NSDecimalNumber(decimal: Decimal(price))
        guard let priceString = numberFormatter.string(from: decimalPrice) else {
            return []
        }
        
        var result: [PriceComponent] = []
        var isDecimalSeparatorPassed = false
        
        priceString.forEach { char in
            let stringChar = String(char)
            switch stringChar {
            case numberFormatter.currencySymbol:
                result.append(.currencySymbol(stringChar))
                
            case numberFormatter.groupingSeparator:
                result.append(.groupingSeparator(value: stringChar))
                
            case numberFormatter.decimalSeparator:
                result.append(.decimalSeparator(value: stringChar))
                isDecimalSeparatorPassed = true
                
            default:
                guard char.isNumber, let value = Int(stringChar) else {
                    break
                }
                result.append(.number(value: value, isDecimal: isDecimalSeparatorPassed))
            }
        }
        
        return result
    }
    
    static func createPriceComponents(oldPriceComponents: [PriceComponent],
                                      newPrice: Double,
                                      usingFormatter numberFormatter: NumberFormatter) -> [PriceComponent] {
        let oldPrice = PriceComponent.createPrice(from: oldPriceComponents, usingFormatter: numberFormatter)
        
        guard let oldPriceString = numberFormatter.string(from: NSDecimalNumber(decimal: Decimal(oldPrice))),
              let newPriceString = numberFormatter.string(from: NSDecimalNumber(decimal: Decimal(newPrice))) else {
            return []
        }
        
        let changedIndex = oldPriceString
            .enumerated()
            .first(where: {
                let index = String.Index(utf16Offset: $0.offset, in: newPriceString)
                return $0.element != newPriceString[index]
            })?.offset
        ?? newPriceString.count - 1
        
        var result: [PriceComponent] = []
        var isDecimalSeparatorPassed = false
        
        newPriceString.enumerated().forEach { i, char in
            let stringChar = String(char)
            switch stringChar {
            case numberFormatter.currencySymbol:
                result.append(.currencySymbol(stringChar))
                
            case numberFormatter.groupingSeparator:
                let nextNumberIndex = i + 1
                let isHighlighted = nextNumberIndex >= changedIndex
                result.append(
                    .groupingSeparator(id: isHighlighted ? UUID().uuidString : oldPriceComponents[i].id,
                                       value: stringChar,
                                       isHighlighted: isHighlighted)
                )
                
            case numberFormatter.decimalSeparator:
                let nextNumberIndex = i + 1
                let isHighlighted = nextNumberIndex >= changedIndex
                result.append(
                    .decimalSeparator(id: isHighlighted ? UUID().uuidString : oldPriceComponents[i].id,
                                      value: stringChar,
                                      isHighlighted: isHighlighted)
                )
                isDecimalSeparatorPassed = true
                
            default:
                guard char.isNumber, let value = Int(stringChar) else {
                    break
                }
                let isHighlighted = i >= changedIndex
                result.append(
                    .number(id: isHighlighted ? UUID().uuidString : oldPriceComponents[i].id,
                            value: value,
                            isDecimal: isDecimalSeparatorPassed,
                            isHighlighted: isHighlighted)
                )
            }
        }
        return result
    }
}

// MARK: - Double factory

extension PriceComponent {
    
    static func createPrice(from priceComponents: [PriceComponent],
                            usingFormatter numberFormatter: NumberFormatter) -> Double {
        let priceString = priceComponents.map { $0.stringValue }.joined()
        return numberFormatter.number(from: priceString)?.doubleValue ?? .zero
    }
}
