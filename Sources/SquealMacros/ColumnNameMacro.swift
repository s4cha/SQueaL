//
//  ColumnNameMacro.swift
//  Squeal
//

import SwiftSyntax
import SwiftSyntaxMacros

/// `@ColumnName("…")` generates nothing. It marks a property so `TableMacro` uses the given
/// name as the database column name.
public struct ColumnNameMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}
