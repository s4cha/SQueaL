//
//  SQL+OR.swift
//  
//
//  Created by DURAND SAINT OMER Sacha on 28/03/2024.
//

import Foundation


public extension WhereSQLQuery {
    func OR(_ clause: String) -> WhereSQLQuery {
        return WhereSQLQuery(query: query + " OR \(clause)", parameters: [])
    }
}
