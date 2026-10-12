//
//  Table.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


/// A database table that queries can read from and write to.
///
/// You usually get a conforming type from the ``Table(schema:)`` macro. You can also write
/// one by hand, declaring each column with the `Column` property wrapper:
///
/// ```swift
/// struct UsersTable: Table {
///     static let schema = "users"
///     @Column<UUID>(name: "id") var id
///     @Column<String>(name: "email_address") var email
/// }
/// ```
public protocol Table: Sendable {
    /// The name of the table in the database.
    static var schema: String { get }
    /// Creates a value that describes the table.
    init()
}
