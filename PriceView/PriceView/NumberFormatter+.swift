//
//  NumberFormatter+.swift
//  ticker-price
//
//  Created by Fedor Prokhorov on 30.03.2023.
//

import Foundation

extension NumberFormatter {
    
    static let usNumberFormatter: NumberFormatter = {
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
}
