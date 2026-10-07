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


struct JOIN_ORDER_BYTests {
    
    @Test
    func JOIN_WHERE_ORDER_BY_joinedColumn() {
        let userId = UUID()
        let query = SQL
            .SELECT(departments.id, departments.name)
            .FROM(departments)
            .JOIN(users_departments, ON: users_departments.department_id == departments.id)
            .WHERE(users_departments.user_id == userId)
            .ORDER_BY(users_departments.department_id, .ASC)
        #expect(query.query == "SELECT departments.id, departments.name FROM departments JOIN users_departments ON users_departments.department_id = departments.id WHERE users_departments.user_id = $1 ORDER BY users_departments.department_id ASC")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? UUID == userId)
    }
}

struct JOIN_WHERE_qualifiedColumnsTests {
    
    @Test
    func JOIN_WHERE_IN_subquery_and_optionalFilters() {
        let userId = UUID()
        let minAge: Int? = 18
        let maxAge: Int? = nil
        var filter = SQL
            .SELECT(users.name, departments.name, RawSQL("upper(departments.name)"))
            .FROM(users_departments)
            .JOIN(users, ON: users.uuid == users_departments.user_id)
            .JOIN(departments, ON: departments.id == users_departments.department_id)
            .WHERE(departments.id, IN: SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId))
        if let minAge { filter = filter.AND(users.age >= minAge) }
        if let maxAge { filter = filter.AND(users.age <= maxAge) }
        filter = filter.AND(users_departments.user_id == userId)
        let query = filter.ORDER_BY(users.age, .DESC)
        
        #expect(query.query == "SELECT users.name, departments.name, upper(departments.name) FROM users_departments JOIN users ON users.uuid = users_departments.user_id JOIN departments ON departments.id = users_departments.department_id WHERE departments.id IN (SELECT department_id FROM users_departments WHERE user_id = $1) AND users.age >= $2 AND users_departments.user_id = $3 ORDER BY users.age DESC")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[0] as? UUID == userId)
        #expect(query.parameters[1] as? Int == 18)
        #expect(query.parameters[2] as? UUID == userId)
    }
    
    @Test
    func qualifiedColumnComparisonOperators() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(users.age > 1)
            .AND(users.age < 2)
            .AND(users.age >= 3)
            .AND(users.age <= 4)
            .AND(users.name != "Bob")
        #expect(query.query == "SELECT id FROM users WHERE users.age > $1 AND users.age < $2 AND users.age >= $3 AND users.age <= $4 AND users.name != $5")
        #expect(query.parameters.count == 5)
    }
}
