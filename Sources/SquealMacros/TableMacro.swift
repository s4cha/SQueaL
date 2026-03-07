//
//  TableMacro.swift
//  Squeal
//
//  Created by Sacha Durand Saint Omer on 02/01/2026.
//

import SwiftSyntax
import SwiftSyntaxMacros

public struct TableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Must be applied to a struct
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw MacroError("@Table can only be applied to a struct")
        }

        // Extract schema name from @Table(schema: "...")
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let schemaArg = arguments.first(where: { $0.label?.text == "schema" }),
              let schemaLiteral = schemaArg.expression.as(StringLiteralExprSyntax.self),
              let schemaValue = schemaLiteral.segments.first?.as(StringSegmentSyntax.self)?.content.text
        else {
            throw MacroError("@Table requires a 'schema' argument, e.g. @Table(schema: \"users\")")
        }

        let structName = structDecl.name.text
        let generatedName = "\(structName)Table"

        // Collect stored properties
        var columnDecls = [String]()
        for member in structDecl.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  varDecl.bindingSpecifier.text == "var" || varDecl.bindingSpecifier.text == "let",
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                  let typeAnnotation = binding.typeAnnotation
            else {
                continue
            }

            // Skip computed properties (those with accessors)
            if binding.accessorBlock != nil {
                continue
            }

            let propertyName = identifier.identifier.text

            // Check for @ColumnName("custom") attribute
            var columnName = propertyName
            for attribute in varDecl.attributes {
                if let attr = attribute.as(AttributeSyntax.self),
                   let attrName = attr.attributeName.as(IdentifierTypeSyntax.self),
                   attrName.name.text == "ColumnName",
                   let args = attr.arguments?.as(LabeledExprListSyntax.self),
                   let firstArg = args.first,
                   let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
                   let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                    columnName = segment.content.text
                }
            }

            // Get the type as written (handles optionals, generics, etc.)
            let typeText = typeAnnotation.type.trimmedDescription

            columnDecls.append("    @Column<\(typeText)>(name: \"\(columnName)\") var \(propertyName)")
        }

        let columnsBlock = columnDecls.joined(separator: "\n")

        let generatedStruct: DeclSyntax = """
        struct \(raw: generatedName): Table {
            static let schema = \"\(raw: schemaValue)\"
        \(raw: columnsBlock)
        }
        """

        return [generatedStruct]
    }
}

struct MacroError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) {
        self.description = description
    }
}
