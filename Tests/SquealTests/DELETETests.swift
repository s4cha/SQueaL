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
    func DELETEwithoutWHERE_isNotARunnableQuery() {
        let builders: [Any] = [SQL.DELETE.FROM(users), SQL.DELETE(FROM: users), SQL.DELETE_FROM(users)]
        for builder in builders {
            #expect(!(builder is any SQLQuery))
            #expect((builder as? any SQLFragment)?.query == "DELETE FROM users")
        }
    }

    @Test
    func DELETEeveryRowOnPurpose() {
        let query = SQL.DELETE(FROM: users).WHERE(SQLExpr("true"))
        #expect(query.query == "DELETE FROM users WHERE true")
        #expect(query.parameters.isEmpty)
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
      let query: SQLQuery = SQL
            .DELETE_FROM(users)
            .WHERE(\.id == 1)
            .RETURNING(\.id, \.name)
        #expect(query.query == "DELETE FROM users WHERE id = $1 RETURNING id, name")
    }
  
  
  @Test
  func DELETEFROMNotRunnable() {
      // `let query: SQLQuery = SQL.DELETE_FROM(users)` doesn't compile: without WHERE it can't run.
      let query = SQL
          .DELETE_FROM(users)
      #expect(!((query as Any) is any SQLQuery))
  }
  
  @Test
  func DELETEFROMNotRunnable2() {
      // `let query: SQLQuery = SQL.DELETE.FROM(users)` doesn't compile: without WHERE it can't run.
      let query = SQL
          .DELETE
          .FROM(users)
      #expect(!((query as Any) is any SQLQuery))
  }
}
