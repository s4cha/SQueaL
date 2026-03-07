//
//  WHERETests.swift
//
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal
import Foundation


struct WHERETests {
    
    @Test
    func WHEREFullString() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE("id = 1")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.query == "SELECT id FROM users WHERE id = $1")
        #expect("\(query)" == "SELECT id FROM users WHERE id = 1")
    }
    
    @Test
    func WHEREInt() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id == 1)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.query == "SELECT id FROM users WHERE id = $1")
        #expect("\(query)" == "SELECT id FROM users WHERE id = 1")
    }
    
    @Test
    func WHEREString() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.name == "Ada")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? String == "Ada")
        #expect(query.query == "SELECT id FROM users WHERE name = $1")
        #expect("\(query)" == "SELECT id FROM users WHERE name = 'Ada'")
    }
    
    @Test
    func WHEREEqual() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id == 1)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.query == "SELECT id FROM users WHERE id = $1")
        #expect("\(query)" == "SELECT id FROM users WHERE id = 1")
    }
    
    @Test
    func WHERESuperior() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id > 42)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 42)
        #expect(query.query == "SELECT id FROM users WHERE id > $1")
        #expect("\(query)" == "SELECT id FROM users WHERE id > 42")
    }
    
    @Test
    func WHERESuperiorOrEqual() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id >= 42)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 42)
        #expect(query.query == "SELECT id FROM users WHERE id >= $1")
        #expect("\(query)" == "SELECT id FROM users WHERE id >= 42")
    }
    
    @Test
    func WHEREInferior() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id < 65)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 65)
        #expect(query.query == "SELECT id FROM users WHERE id < $1")
        #expect("\(query)" == "SELECT id FROM users WHERE id < 65")
    }
    
    @Test
    func WHEREInferiorOrEqual() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id <= 99)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 99)
        #expect(query.query == "SELECT id FROM users WHERE id <= $1")
        #expect("\(query)" == "SELECT id FROM users WHERE id <= 99")
    }
    
    @Test
    func WHEREInList() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.name, IN: ["Alice", "Bob", "Charlie"])
        #expect(query.parameters.count == 3)
        #expect(query.parameters[0] as? String == "Alice")
        #expect(query.parameters[1] as? String == "Bob")
        #expect(query.parameters[2] as? String == "Charlie")
        #expect(query.query == "SELECT * FROM users WHERE name IN ($1, $2, $3)")
        #expect("\(query)" == "SELECT * FROM users WHERE name IN ('Alice', 'Bob', 'Charlie')")
    }
    
    @Test
    func WHERETypeSafeString() throws {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.name == "Alice")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? String == "Alice")
        #expect(query.query == "SELECT * FROM users WHERE name = $1")
        #expect("\(query)" == "SELECT * FROM users WHERE name = 'Alice'")
    }
    
    @Test
    func WHERELike() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.name, LIKE: "%ob")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? String == "%ob")
        #expect(query.query == "SELECT id FROM users WHERE name like $1")
        #expect("\(query)" == "SELECT id FROM users WHERE name like '%ob'")
    }
    
    @Test
    func WHERE_IS_NULL() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.name)
            .IS_NULL
        
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id FROM users WHERE name IS NULL")
        #expect("\(query)" == "SELECT id FROM users WHERE name IS NULL")
    }
    
    @Test
    func WHERE_IS_NOT_NULL() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.name)
            .IS_NOT_NULL
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id FROM users WHERE name IS NOT NULL")
        #expect("\(query)" == "SELECT id FROM users WHERE name IS NOT NULL")
    }
    
    @Test
    func WHERETypeSafeUUID() throws {
        let uuid = UUID(uuidString: "5DC4AC7B-37C1-4472-B1F6-974B79624FE5")!
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.uuid == uuid)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? UUID == UUID(uuidString: "5DC4AC7B-37C1-4472-B1F6-974B79624FE5")!)
        #expect(query.query == "SELECT * FROM users WHERE uuid = $1")
        #expect("\(query)" == "SELECT * FROM users WHERE uuid = '5DC4AC7B-37C1-4472-B1F6-974B79624FE5'")
    }
    
    // AND
    @Test
    func WHEREANDEqualSign() {
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
    
    // OR
    
    @Test
    func WHEREOREqualSign() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id == 1)
            .OR(\.name == "john")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.parameters[1] as? String == "john")
        #expect(query.query == "SELECT id FROM users WHERE id = $1 OR name = $2")
        #expect("\(query)" == "SELECT id FROM users WHERE id = 1 OR name = 'john'")
    }
}
