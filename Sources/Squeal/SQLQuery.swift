//
//  SQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


public protocol SQLQuery: CustomStringConvertible {
    var query: String { get }
    var parameters: [(any Encodable)?] { get }
}
