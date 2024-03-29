//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal

struct DB {
    static let users = UsersTable()
}

struct UsersTable: Table {
    let tableName = "users"
    let id = Field<Int>(name: "id")
    let name = Field<String>(name: "name")
}


final class TypedQueryTests: XCTestCase {
    
    var sut: TypedSQLQuery<UsersTable>!
    
    override func setUp() async throws {
        self.sut = TypedSQLQuery(for: DB.users)
    }
    
    func testTypesafeFullQuery() {
        let query = sut
            .SELECT(\.id)
            .FROM(DB.users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "Jack")
        XCTAssertEqual(query.raw, "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testTypesafeFullQueryOmmittingFrom() {
        let query = sut
            .SELECT(\.id)
            .FROM(DB.users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "Jack")
        XCTAssertEqual(query.raw, "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testSelectTypesShortKeypath() {
        let query2 = sut
            .SELECT(\.name)
        XCTAssertEqual(query2.raw, "SELECT name")
    }
    
    func testWhereTypeSafe() throws {
        let query = sut
            .SELECT(.all)
            .FROM(DB.users)
            .WHERE(\.id, equals: 1)
        print(query)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1")
    }
    
    func testAndTypeSafe() throws {
        let query = sut
            .SELECT(.all)
            .FROM(DB.users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "jack")
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
    
    func testAndTypeSafeLimit() throws {
        let query = sut
            .SELECT(.all)
            .FROM(DB.users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "jack")
            .LIMIT(1)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 1")
    }
    
    func testDelete() {
        let query = sut
            .DELETE()
            .FROM(DB.users)
            .WHERE(\.id, equals: 243)
        XCTAssertEqual(query.raw, "DELETE FROM users WHERE id = 243")
    }

    // - MARK: Helpers
    
    func testAll() {
        let query = sut.all()
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
    func testTableAll() {
        let query = UsersTable().all()
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
    func testFind() {
        let query = sut.find(\.id, equals: 12)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
    }
    
    func testFindTable() {
        let query = DB.users.find(\.id, equals: 12)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
    }
}


