//
//  SQLQuery.swift
//
//
//  Created by Sacha Durand Saint Omer on 26/03/2024.
//

import Foundation


protocol SQLQuery: CustomStringConvertible{
    var raw: String { get }
}

extension SQLQuery {
    var description: String { return raw }
}
