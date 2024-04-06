//
//  BareSQLQuery.swift
//  
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public struct BareSQLQuery: SQLQuery {
    public var query: String
    public var parameters: [(any Encodable)?]
}
