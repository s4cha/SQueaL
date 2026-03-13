//
//  ANDTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct ANDTests {
    
    @Test
    func ANDEqualSign() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name == "Jack")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.parameters[1] as? String == "Jack")
        #expect(query.query == "SELECT id FROM users WHERE id = $1 AND name = $2")
        #expect("\(query)" == "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    @Test
    func ANDTypeSafe() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name == "jack")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.parameters[1] as? String == "jack")
        #expect(query.query == "SELECT * FROM users WHERE id = $1 AND name = $2")
        #expect("\(query)" == "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
    
    @Test
    func tripleAND() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name == "Alice")
            .AND(\.age == 30)
        #expect(query.parameters.count == 3)
        #expect(query.query == "SELECT * FROM users WHERE id = $1 AND name = $2 AND age = $3")
        #expect("\(query)" == "SELECT * FROM users WHERE id = 1 AND name = 'Alice' AND age = 30")
    }
    
    @Test
    func multipleOR() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .OR(\.id == 2)
            .OR(\.id == 3)
        #expect(query.parameters.count == 3)
        #expect(query.query == "SELECT * FROM users WHERE id = $1 OR id = $2 OR id = $3")
        #expect("\(query)" == "SELECT * FROM users WHERE id = 1 OR id = 2 OR id = 3")
    }

    @Test
    func ANDthenOR() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name == "Alice")
            .OR(\.age == 25)
        #expect(query.parameters.count == 3)
        #expect(query.query == "SELECT * FROM users WHERE id = $1 AND name = $2 OR age = $3")
        #expect("\(query)" == "SELECT * FROM users WHERE id = 1 AND name = 'Alice' OR age = 25")
    }

    @Test
    func ORthenAND() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .OR(\.name == "Bob")
            .AND(\.age == 30)
        #expect(query.parameters.count == 3)
        #expect(query.query == "SELECT * FROM users WHERE id = $1 OR name = $2 AND age = $3")
        #expect("\(query)" == "SELECT * FROM users WHERE id = 1 OR name = 'Bob' AND age = 30")
    }

    @Test
    func ANDwithIN() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.age > 18)
            .AND(\.name, IN: ["Alice", "Bob"])
        #expect(query.query == "SELECT * FROM users WHERE age > $1 AND name IN ($2, $3)")
    }

    @Test
    func ORwithIN() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.age > 18)
            .OR(\.name, IN: ["Alice", "Bob"])
        #expect(query.query == "SELECT * FROM users WHERE age > $1 OR name IN ($2, $3)")
    }

    @Test
    func ANDwithLIKE() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name, LIKE: "%alice%")
        #expect(query.query == "SELECT * FROM users WHERE id = $1 AND name LIKE $2")
    }

    @Test
    func ORwithLIKE() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .OR(\.name, LIKE: "%bob%")
        #expect(query.query == "SELECT * FROM users WHERE id = $1 OR name LIKE $2")
    }
}
