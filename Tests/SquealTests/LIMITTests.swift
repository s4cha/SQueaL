//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class LimitTests: XCTestCase {
    
    let users = UsersTable()
    let trades = TradesTable()
        
    func testLimitAfterFROM() throws {
        let query = SQL
            .SELECT(.all, FROM: users)
            .LIMIT(17)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT * FROM users LIMIT 17")
        XCTAssertEqual("\(query)", "SELECT * FROM users LIMIT 17")
    }
    
    func testLimitAfterWHERE() throws {
        let query = SQL
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 34)
        
        
            .LIMIT(17)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE id = $1 LIMIT 17")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 34 LIMIT 17")
    }
    
    func testLimitAfterAND() throws {
        let query = SQL
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
            .AND(\UsersTable.name == "jack")
            .LIMIT(1)
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "jack")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE id = $1 AND name = $2 LIMIT 1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 1")
    }
    
    func testLimitAfterGROUP_BY() throws {
        let query = SQL
            .SELECT(\.name, FROM: users)
            .WHERE(\.id == 1)
            .AND(\.name == "jack")
            .GROUP_BY(\.name)
            .LIMIT(3)
        
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "jack")
        XCTAssertEqual(query.query, "SELECT name FROM users WHERE id = $1 AND name = $2 GROUP BY name LIMIT 3")
        XCTAssertEqual("\(query)", "SELECT name FROM users WHERE id = 1 AND name = 'jack' GROUP BY name LIMIT 3")
    }
}




//[HAVING ...]
//[ORDER BY ...]

