//
//  SQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public protocol SQLQuery: CustomStringConvertible {
    var raw: String { get }
}

public extension SQLQuery {
    var description: String { return raw }
}
