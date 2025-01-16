//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class GROUP_BYTests: XCTestCase {
    
    let users = UsersTable()
    
    func testGROUP_BYafterSELECT() throws {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .GROUP_BY(\.name)
        
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT name FROM users GROUP BY name")
        XCTAssertEqual("\(query)", "SELECT name FROM users GROUP BY name")
    }
    
    func testGROUP_BYafterWHERE() throws {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id == 12)
            .GROUP_BY(\.id)

        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 12)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1 GROUP BY id")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 12 GROUP BY id")
    }
    
    func testGROUP_BYafterAND() throws {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id == 12)
            .AND(\.name == "jack")
            .GROUP_BY(\.id)
    
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 12)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1 AND name = $2 GROUP BY id")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 12 AND name = 'jack' GROUP BY id")
    }
}
