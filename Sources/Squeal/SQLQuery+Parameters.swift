//
//  SQLQuery+Parameters.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 11/04/2024.
//

import Foundation


public extension SQLQuery {
    
    func nextDollarSign() -> String {
        return "$\(parameterNumber() + 1)"
    }
    
    func parameterNumber() -> Int {
        return query.filter { $0 == "$" }.count
    }
}
