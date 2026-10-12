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
/// Computed properties are skipped. To use a different column name than the property
/// name, mark the property with ``ColumnName(_:)``.
///
/// - Parameter schema: The name of the table in the database.
@attached(peer, names: suffixed(Table))
public macro Table(schema: String) = #externalMacro(module: "SquealMacros", type: "TableMacro")

/// Sets the database column name of a property in a ``Table(schema:)`` struct.
///
/// Use it when your Swift property name differs from the column name, such as a
/// `camelCase` property for a `snake_case` column:
///
/// ```swift
/// @Table(schema: "users")
/// struct User {
///     let id: UUID
///     @ColumnName("email_address") let email: String
///     @ColumnName("created_at") let createdAt: Date
/// }
///
/// SQL.SELECT(\.id, \.email).FROM(users)
/// // SELECT id, email_address FROM users
/// ```
///
/// In Swift you keep using the property name (`\.email`, `users.email`). The generated SQL
/// uses the column name. The attribute has no effect outside a `@Table` struct.
///
/// - Parameter name: The name of the column in the database.
@attached(peer)
public macro ColumnName(_ name: String) = #externalMacro(module: "SquealMacros", type: "ColumnNameMacro")
