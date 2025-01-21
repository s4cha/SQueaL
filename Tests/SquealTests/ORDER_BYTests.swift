//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class ORDER_BYTests: XCTestCase {
    
    let users = UsersTable()
    
    func testORDER_BYafterSELECT() throws {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id, name FROM users ORDER BY name")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users ORDER BY name")
    }
    
    func testORDER_BY_ASC_afterSELECT() throws {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name, .ASC)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id, name FROM users ORDER BY name ASC")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users ORDER BY name ASC")
    }
    
    func testMultipleORDER_BY_afterSELECT() throws {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY((\.id, .ASC), (\.name, .DESC))
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id, name FROM users ORDER BY id ASC, name DESC")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users ORDER BY id ASC, name DESC")
    }
    
    func testORDER_BY_ASC2_afterSELECT() throws {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name).ASC
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id, name FROM users ORDER BY name ASC")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users ORDER BY name ASC")
    }
    
    func testORDER_BY_DESC_afterSELECT() throws {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name, .DESC)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id, name FROM users ORDER BY name DESC")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users ORDER BY name DESC")
    }
    
    func testORDER_BY_DESC2_afterSELECT() throws {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name).DESC
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id, name FROM users ORDER BY name DESC")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users ORDER BY name DESC")
    }
    
    func testORDER_BYafterWHERE() throws {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .WHERE(\.id > 12)
            .ORDER_BY(\.name)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssertEqual(query.query, "SELECT id, name FROM users WHERE id > $1 ORDER BY name")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users WHERE id > 12 ORDER BY name")
    }
}
