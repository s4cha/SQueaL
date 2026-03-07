//
//  Macros.swift
//  Squeal
//
//  Created by Sacha Durand Saint Omer on 07/03/2026.
//

@attached(peer, names: suffixed(Table))
public macro Table(schema: String) = #externalMacro(module: "SquealMacros", type: "TableMacro")
