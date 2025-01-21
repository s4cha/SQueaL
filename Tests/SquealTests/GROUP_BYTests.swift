//
//  GROUP_BYTests.swift
//
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct GROUP_BYTests {
    
    @Test
    func GROUP_BYafterSELECT() {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .GROUP_BY(\.name)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT name FROM users GROUP BY name")
        #expect("\(query)" == "SELECT name FROM users GROUP BY name")
    }
    
    @Test
    func testGROUP_BYafterWHERE() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id == 12)
            .GROUP_BY(\.id)
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 12)
        #expect(query.query == "SELECT id FROM users WHERE id = $1 GROUP BY id")
        #expect("\(query)" == "SELECT id FROM users WHERE id = 12 GROUP BY id")
    }
    
    @Test
    func testGROUP_BYafterAND() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.id == 12)
            .AND(\.name == "jack")
            .GROUP_BY(\.id)
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 12)
        #expect(query.query == "SELECT id FROM users WHERE id = $1 AND name = $2 GROUP BY id")
        #expect("\(query)" == "SELECT id FROM users WHERE id = 12 AND name = 'jack' GROUP BY id")
    }
}
