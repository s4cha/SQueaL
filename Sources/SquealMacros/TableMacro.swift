//
//  TableMacro.swift
//  Squeal
//
//  Created by Sacha Durand Saint Omer on 02/01/2026.
//

import SwiftSyntax
import SwiftSyntaxMacros

//public struct TableMacro: MemberAttributeMacro {
//    public static func expansion(
//        of node: AttributeSyntax,
//        attachedTo declaration: some DeclGroupSyntax,
//        providingAttributesFor member: some DeclSyntaxProtocol,
//        in context: some MacroExpansionContext
//    ) throws -> [AttributeSyntax] {
//        // Only process variable declarations
//        guard let varDecl = member.as(VariableDeclSyntax.self),
//              varDecl.isStoredProperty,  // Ensure it's a stored property (no computed props)
//              let binding = varDecl.bindings.first,
//              let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
//              let typeAnnotation = binding.typeAnnotation,
//              !typeAnnotation.type.is(OptionalTypeSyntax.self),  // Optional: skip optionals if undesired
//              let typeName = typeAnnotation.type.as(IdentifierTypeSyntax.self)?.name.text  // Assume simple types for now
//        else {
//            return []
//        }
//        
//        let propertyName = identifier.identifier.text
//        
//        // Build the generic argument for @Column<Type>
//        let genericClause = GenericArgumentClauseSyntax(
//            leftAngleBracket: .leftAngleToken(),
//            arguments: .init([GenericArgumentSyntax(argument: IdentifierTypeSyntax(name: .identifier(typeName)))]),
//            rightAngleBracket: .rightAngleToken()
//        )
//        
//        // Build the attribute name: Column with generic
//        let attributeName = IdentifierTypeSyntax(
//            name: .identifier("Column"),
//            genericArgumentClause: genericClause
//        )
//        
//        // Build the argument list: (name: "propertyName")
//        let argList = LabeledExprListSyntax {
//            LabeledExprSyntax(
//                label: "name",
//                colon: .colonToken(),
//                expression: StringLiteralExprSyntax(content: propertyName)
//            )
//        }
//        
//        // Construct the full @Column<Type>(name: "propertyName") attribute
//        let attribute = AttributeSyntax(
//            atSign: .atSignToken(),
//            attributeName: attributeName,
//            leftParen: .leftParenToken(),
//            arguments: .argumentList(argList),
//            rightParen: .rightParenToken()
//        )
//        
//        return [attribute]
//    }
//}
