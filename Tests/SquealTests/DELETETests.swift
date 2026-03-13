//
//  DELETETests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct DELETETests {
    
    @Test
    func DELETE() {
        let query = SQL
            .DELETE_FROM(users)
            .WHERE(\.id == 243)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 243)
        #expect(query.query == "DELETE FROM users WHERE id = $1")
        #expect("\(query)" == "DELETE FROM users WHERE id = 243")
    }
    
    @Test
    func DELETE2() {
        let query = SQL
            .DELETE(FROM: users)
            .WHERE(\.id == 243)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 243)
        #expect(query.query == "DELETE FROM users WHERE id = $1")
        #expect("\(query)" == "DELETE FROM users WHERE id = 243")
    }
    
    @Test
    func DELETE3() {
        let query = SQL
            .DELETE
            .FROM(users)
            .WHERE(\.id == 243)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 243)
        #expect(query.query == "DELETE FROM users WHERE id = $1")
        #expect("\(query)" == "DELETE FROM users WHERE id = 243")
    }
    
    @Test
    func DELETEwithoutWHERE() {
        let query = SQL
            .DELETE
            .FROM(users)
        #expect(query.query == "DELETE FROM users")
        #expect("\(query)" == "DELETE FROM users")
    }

    @Test
    func DELETEwithWHEREandAND() {
        let query = SQL
            .DELETE
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name == "test")
        #expect(query.parameters.count == 2)
        #expect(query.query == "DELETE FROM users WHERE id = $1 AND name = $2")
        #expect("\(query)" == "DELETE FROM users WHERE id = 1 AND name = 'test'")
    }

    @Test
    func DELETEwithWHEREandOR() {
        let query = SQL
            .DELETE
            .FROM(users)
            .WHERE(\.id == 1)
            .OR(\.id == 2)
        #expect(query.parameters.count == 2)
        #expect(query.query == "DELETE FROM users WHERE id = $1 OR id = $2")
    }
    
    @Test
    func DELETEwithRETURNINGAll() {
        let query = SQL
            .DELETE_FROM(users)
            .WHERE(\.id == 1)
            .RETURNING(*)
        #expect(query.query == "DELETE FROM users WHERE id = $1 RETURNING *")
    }
    
    @Test
    func DELETEwithRETURNINGid() {
        let query = SQL
            .DELETE_FROM(users)
            .WHERE(\.id == 1)
            .RETURNING(\.id)
        #expect(query.query == "DELETE FROM users WHERE id = $1 RETURNING id")
    }
    
    @Test
    func DELETEwithRETURNINGmultipleColumns() {
        let query = SQL
            .DELETE_FROM(users)
            .WHERE(\.id == 1)
            .RETURNING(\.id, \.name)
        #expect(query.query == "DELETE FROM users WHERE id = $1 RETURNING id, name")
    }
}
