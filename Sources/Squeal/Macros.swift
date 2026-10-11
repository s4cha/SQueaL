//
//  Macros.swift
//  Squeal
//
//  Created by Sacha Durand Saint Omer on 07/03/2026.
//

/// Generates a ``Table`` type from a struct that describes a database table.
///
/// ```swift
/// @Table(schema: "users")
/// struct User {
///     let id: UUID
///     let name: String
///     let bio: String?
/// }
///
/// let users = UserTable()
/// SQL.SELECT(\.id, \.name).FROM(users)
/// ```
///
/// The macro adds a peer struct named after the annotated struct with a `Table` suffix.
/// It declares one ``TableColumn`` per stored property, with the property's name and type.
/// Computed properties are skipped.
///
/// - Parameter schema: The name of the table in the database.
@attached(peer, names: suffixed(Table))
public macro Table(schema: String) = #externalMacro(module: "SquealMacros", type: "TableMacro")
