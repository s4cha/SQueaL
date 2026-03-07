//
//  JOINTests.swift
//
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Foundation
import Testing
import Squeal


struct JOINTests {
    
    @Test
    func JOIN() {
        let query = TSQL
            .SELECT((\.name, AS: "username"))
            .FROM(users)
            .JOIN(orders, ON: users.uuid == orders.user_id)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT name AS username FROM users JOIN orders ON users.uuid = orders.user_id")
        #expect("\(query)" == "SELECT name AS username FROM users JOIN orders ON users.uuid = orders.user_id")
    }
    
    @Test
    func JOINReverseON() {
        let query = TSQL
            .SELECT((\.name, AS: "username"))
            .FROM(users)
            .JOIN(orders, ON: orders.user_id == users.uuid)
            
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT name AS username FROM users JOIN orders ON orders.user_id = users.uuid")
        #expect("\(query)" == "SELECT name AS username FROM users JOIN orders ON orders.user_id = users.uuid")
    }
    
    @Test
    func INNER_JOIN() {
        let query = TSQL
            .SELECT((\.name, AS: "username"))
            .FROM(users)
            .INNER_JOIN(orders, ON: users.uuid == orders.user_id)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT name AS username FROM users INNER JOIN orders ON users.uuid = orders.user_id")
        #expect("\(query)" == "SELECT name AS username FROM users INNER JOIN orders ON users.uuid = orders.user_id")
    }
    
    @Test
    func LEFT_JOIN() {
        let query = TSQL
            .SELECT((\.name, AS: "username"))
            .FROM(users)
            .LEFT_JOIN(orders, ON: users.uuid == orders.user_id)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT name AS username FROM users LEFT JOIN orders ON users.uuid = orders.user_id")
        #expect("\(query)" == "SELECT name AS username FROM users LEFT JOIN orders ON users.uuid = orders.user_id")
    }
    
    @Test
    func RIGHT_JOIN() {
        let query = TSQL
            .SELECT((\.name, AS: "username"))
            .FROM(users)
            .RIGHT_JOIN(orders, ON: users.uuid == orders.user_id)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT name AS username FROM users RIGHT JOIN orders ON users.uuid = orders.user_id")
        #expect("\(query)" == "SELECT name AS username FROM users RIGHT JOIN orders ON users.uuid = orders.user_id")
    }
    
    @Test
    func FULL_OUTER_JOIN() {
        let query = TSQL
            .SELECT((\.name, AS: "username"))
            .FROM(users)
            .FULL_OUTER_JOIN(orders, ON: users.uuid == orders.user_id)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT name AS username FROM users FULL OUTER JOIN orders ON users.uuid = orders.user_id")
        #expect("\(query)" == "SELECT name AS username FROM users FULL OUTER JOIN orders ON users.uuid = orders.user_id")
    }

    
    @Test
    func testCommon1() {        
        let query = SQL
            .SELECT(employees.name, departments.name) // TODO (AS department)
            .FROM(employees)
            .INNER_JOIN(departments, ON: employees.department_id == departments.id)
        #expect("\(query)" == "SELECT employees.name, departments.name FROM employees INNER JOIN departments ON employees.department_id = departments.id")
    }
    
    
    @Test
    func JOINWhere() {
        // List user departments many to many relationship
        let userId = UUID(uuidString: "485DBC0B-4C82-4442-BB2A-1879D4E28A14")!
        let query = SQL
            .SELECT(departments.id, departments.name)
            .FROM(departments)
            .JOIN(users_departments, ON: departments.id == users_departments.user_id)
            .WHERE("users_departments.user_id = \(userId)")
        #expect("\(query)" == "SELECT departments.id, departments.name FROM departments JOIN users_departments ON departments.id = users_departments.user_id WHERE users_departments.user_id = '485DBC0B-4C82-4442-BB2A-1879D4E28A14'")
    }
    
    
    @Test
    func JOINWhereTypedv1() {
        // List user departments many to many relationship
        let userId = UUID(uuidString: "485DBC0B-4C82-4442-BB2A-1879D4E28A14")!
        let query = SQL
            .SELECT(departments.id, departments.name)
            .FROM(departments)
            .JOIN(users_departments, ON: departments.id == users_departments.user_id)
            .WHERE(users_departments.user_id == userId)
        #expect("\(query)" == "SELECT departments.id, departments.name FROM departments JOIN users_departments ON departments.id = users_departments.user_id WHERE users_departments.user_id = '485DBC0B-4C82-4442-BB2A-1879D4E28A14'")
    }
    
    
    @Test
    func JOINWhereTypedv2() {
        // List user departments many to many relationship
        let userId = UUID(uuidString: "485DBC0B-4C82-4442-BB2A-1879D4E28A14")!
        let query = SQL
            .SELECT(departments.id, departments.name)
            .FROM(departments)
            .JOIN(users_departments, ON: departments.id == users_departments.user_id)
            .WHERE(\UsersDepartmentsTable.user_id == userId)
        #expect("\(query)" == "SELECT departments.id, departments.name FROM departments JOIN users_departments ON departments.id = users_departments.user_id WHERE users_departments.user_id = '485DBC0B-4C82-4442-BB2A-1879D4E28A14'")
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

