//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


struct UsersTable: Table {
    let tableName = "users"
    let id = Field<Int>(name: "id")
    let name = Field<String>(name: "name")
}


final class TypedQueryTests: XCTestCase {
    
    let users = UsersTable()
    
    func testTypesafeFullQuery3() {
        let query = ""
            .SELECT(\.id, FROM: users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "Jack")
        XCTAssertEqual(query.raw, "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testTypesafeFullQuery2() {
        let query = ""
            .SELECT(\.id, FROM: users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "Jack")
        XCTAssertEqual(query.raw, "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testTypesafeFullQuery() {
            
        let query = ""
            .SELECT(\.id, FROM: users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "Jack")
        
        
//        let query = ""
//            .SELECT(\.id, FROM: users)
////            .WHERE(\.id == 1)
////            .AND(\.name == "Jack")
        
        XCTAssertEqual(query.raw, "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testTypesafeFullQueryOmmittingFrom() {
        let query = ""
            .SELECT(\.id, FROM: users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "Jack")
        XCTAssertEqual(query.raw, "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testSelectTypesShortKeypath() {
        let query2 = ""
            .SELECT(\.name, FROM: users)
        XCTAssertEqual(query2.raw, "SELECT name FROM users")
    }
    
    func testWhereTypeSafe() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.id, equals: 1)
        print(query)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1")
    }
    
    func testAndTypeSafe() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "jack")
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
    
    func testAndTypeSafeLimit() throws {
        let query = ""
            .SELECT(.all, FROM: users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "jack")
            .LIMIT(1)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 1")
    }
    
    func testDelete() {
        let query = ""
            .DELETE(FROM: users)
            .WHERE(\.id, equals: 243)
        XCTAssertEqual(query.raw, "DELETE FROM users WHERE id = 243")
    }

    // - MARK: Helpers
    
    func testTableAll() {
        let query = users.all()
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
    func testFind() {
        let query = users.find(\.id, equals: 12)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
    }
    
    func testFindTable() {
        let query = users.find(\.id, equals: 12)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
    }
}


