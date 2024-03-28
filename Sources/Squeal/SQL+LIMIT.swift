//
//  SQL+LIMIT.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


extension SQLQuery {
    
    func LIMIT(_ value: Int) -> SQLQuery {
        return BareSQLQuery(raw: raw + " " + "LIMIT \(value)")
    }
}


extension FromSQLQuery {
    
    func LIMIT(_ value: Int) -> SQLQuery {
        return BareSQLQuery(raw: raw + " " + "LIMIT \(value)")
    }
}


struct LimitSQLQuery {
    let raw: String
}
