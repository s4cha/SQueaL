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
}
