//
//  ParameterizedQueryTests.swift
//
//
//  Created by Sacha Durand Saint Omer on 05/04/2024.
//

import XCTest
@testable import Squeal

final class ParameterizedQueryTests: XCTestCase {
    
    let users = UsersTable()
    
    func testIntParam() {
        let query = ""
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1")
    }
    
    func testStringParam() {
        let query = ""
            .SELECT(\.id, FROM: users)
            .WHERE(\.name == "Ada")
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? String == "Ada")
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE name = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE name = 'Ada'")
    }
}

