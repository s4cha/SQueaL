//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class JOINTests: XCTestCase {
    
    let users = UsersTable()
    let orders = OrdersTable()
    
    func testJOIN() {
        let query = SQL
            .SELECT((\.name, AS: "username"), FROM: users)
            .JOIN(orders, ON: users.uuid == orders.user_id)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT name AS username FROM users JOIN orders ON users.uuid = orders.user_id")
        XCTAssertEqual("\(query)", "SELECT name AS username FROM users JOIN orders ON users.uuid = orders.user_id")
    }
    
    func testJOINReverseON() {
        let query = SQL
            .SELECT((\.name, AS: "username"), FROM: users)
            .JOIN(orders, ON: orders.user_id == users.uuid)
            
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT name AS username FROM users JOIN orders ON orders.user_id = users.uuid")
        XCTAssertEqual("\(query)", "SELECT name AS username FROM users JOIN orders ON orders.user_id = users.uuid")
    }
    
    func testINNER_JOIN() {
        let query = SQL
            .SELECT((\.name, AS: "username"), FROM: users)
            .INNER_JOIN(orders, ON: users.uuid == orders.user_id)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT name AS username FROM users INNER JOIN orders ON users.uuid = orders.user_id")
        XCTAssertEqual("\(query)", "SELECT name AS username FROM users INNER JOIN orders ON users.uuid = orders.user_id")
    }
    
    func testLEFT_JOIN() {
        let query = SQL
            .SELECT((\.name, AS: "username"), FROM: users)
            .LEFT_JOIN(orders, ON: users.uuid == orders.user_id)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT name AS username FROM users LEFT JOIN orders ON users.uuid = orders.user_id")
        XCTAssertEqual("\(query)", "SELECT name AS username FROM users LEFT JOIN orders ON users.uuid = orders.user_id")
    }
    
    func testRIGHT_JOIN() {
        let query = SQL
            .SELECT((\.name, AS: "username"), FROM: users)
            .RIGHT_JOIN(orders, ON: users.uuid == orders.user_id)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT name AS username FROM users RIGHT JOIN orders ON users.uuid = orders.user_id")
        XCTAssertEqual("\(query)", "SELECT name AS username FROM users RIGHT JOIN orders ON users.uuid = orders.user_id")
    }
    
    func testFULL_OUTER_JOIN() {
        let query = SQL
            .SELECT((\.name, AS: "username"), FROM: users)
            .FULL_OUTER_JOIN(orders, ON: users.uuid == orders.user_id)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT name AS username FROM users FULL OUTER JOIN orders ON users.uuid = orders.user_id")
        XCTAssertEqual("\(query)", "SELECT name AS username FROM users FULL OUTER JOIN orders ON users.uuid = orders.user_id")
    }
    

}

//
//SELECT
//    users.id AS user_id,
//    users.name AS user_name,
//    orders.id AS order_id,
//    orders.amount
//FROM users
//INNER JOIN orders
//    ON users.id = orders.user_id
//WHERE orders.status = 'pending';

