//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class UPDATETests: XCTestCase {
    
    let users = UsersTable()
    
    func testUpdate() {
        let query = SQL
            .UPDATE(users, SET: \.name, value: "john")
            .WHERE(\.id == 12)
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? String == "john")
        XCTAssert(query.parameters[1] as? Int == 12)
        XCTAssertEqual(query.query, "UPDATE users SET name = $1 WHERE id = $2")
        XCTAssertEqual("\(query)", "UPDATE users SET name = 'john' WHERE id = 12")
    }
}
