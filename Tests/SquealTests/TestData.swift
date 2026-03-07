//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Foundation
import Squeal
//
//
//
//import SwiftSyntax
//import SwiftSyntaxMacros

//public struct AutoColumnMacro: MemberAttributeMacro {
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


struct UsersTable: Table {
    
    static let schema = "users"
    
    @Column<UUID>(name: "uuid") var uuid
    @Column<Int>(name: "id") var id
    @Column<String>(name: "name") var name
    @Column<Int>(name: "age") var age
}

// TODO ideal world
//@Table(schema: "users")
//struct UsersTable2: Table {
//    var uuid: UUID
//    @ColumnName("custom_id") var id: UUID
//    var name: String
//    var age: Int
//}


struct TradesTable: Table {
    
    static let schema = "trades"
    
    @Column<UUID>(name: "user_id") var user_id
    @Column<UUID>(name: "study_id") var study_id
    @Column<String>(name: "type") var type
}


struct PersonTable: Table {
    
    static let schema = "people"
    
    @Column<String>(name: "first_name") var firstname
    @Column<String>(name: "last_name") var lastname
}


struct StudiesTable: Table {
    
    static let schema = "studies"
        
    @Column<UUID>(name: "id") var id
    @Column<String?>(name: "prolific_study_id") var prolific_study_id
    @Column<String>(name: "name") var name
    @Column<Double>(name: "starting_cash") var starting_cash
    @Column<Double>(name: "partitioning") var partitioning
    @Column<String?>(name: "completion_link") var completion_link
    @Column<Bool>(name: "shows_results") var shows_results
    @Column<Bool>(name: "allows_fractional_investing") var allows_fractional_investing
}


struct Employees: Table {
    static let schema = "employees"
    @Column<String>(name: "name") var name
    @Column<UUID>(name: "department_id") var department_id
}


struct Departments: Table {
    static let schema = "departments"
    
    @Column<UUID>(name: "id") var id
    @Column<String>(name: "name") var name
}

struct OrdersTable: Table {
    
    static let schema = "orders"

    @Column<UUID>(name: "user_id") var user_id
}

struct RolesTable: Table {
    
    static let schema = "roles"

    @Column<UUID>(name: "id") var id
    @Column<UUID>(name: "name") var name
    
}

struct UsersDepartmentsTable: Table {
    
    static let schema = "users_departments"

    @Column<UUID>(name: "department_id") var department_id
    @Column<UUID>(name: "user_id") var user_id
    
}



let users = UsersTable()
let orders = OrdersTable()
let employees = Employees()
let departments = Departments()
let roles = RolesTable()
let users_departments = UsersDepartmentsTable()

// TODO
// Where =  like NULL NOT NULL
// OR
// Group by
// Order By / ASC DESC NULL NOT NULL
// Having
// UPDATE SET


// JOIN, HAVING, DISTINcT, BETWEEN,  EXISTS NOT EXISTS

// SELECT AS.
