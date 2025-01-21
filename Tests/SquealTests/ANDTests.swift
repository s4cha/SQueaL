//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class ANDTests: XCTestCase {
    
    let users = UsersTable()
    let trades = TradesTable()
    
    
    func testWHEREANDEqualSign() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name == "Jack")
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "Jack")
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1 AND name = $2")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testAndTypeSafe() throws {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name == "jack")
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "jack")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE id = $1 AND name = $2")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
}
