//
//  SQL+AND.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public extension WhereSQLQuery {
    func AND(_ clause: String) -> WhereSQLQuery {
        return WhereSQLQuery(raw: raw + " AND \(clause)")
    }
}
