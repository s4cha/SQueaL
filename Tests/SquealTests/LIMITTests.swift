//
//  LimitTests.swift
//
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct LimitTests {
        
    @Test
    func LIMITAfterFROM() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .LIMIT(17)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT * FROM users LIMIT 17")
        #expect("\(query)" == "SELECT * FROM users LIMIT 17")
    }
    
    @Test
    func LIMITAfterWHERE() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 34)
            .LIMIT(17)
        #expect(query.parameters.count == 1)
        #expect(query.query == "SELECT * FROM users WHERE id = $1 LIMIT 17")
        #expect("\(query)" == "SELECT * FROM users WHERE id = 34 LIMIT 17")
    }
    
    @Test
    func LIMITAfterAND() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\UsersTable.name == "jack")
            .LIMIT(1)
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.parameters[1] as? String == "jack")
        #expect(query.query == "SELECT * FROM users WHERE id = $1 AND name = $2 LIMIT 1")
        #expect("\(query)" == "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 1")
    }
    
    @Test
    func LIMITAfterGROUP_BY() {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name == "jack")
            .GROUP_BY(\.name)
            .LIMIT(3)
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.parameters[1] as? String == "jack")
        #expect(query.query == "SELECT name FROM users WHERE id = $1 AND name = $2 GROUP BY name LIMIT 3")
        #expect("\(query)" == "SELECT name FROM users WHERE id = 1 AND name = 'jack' GROUP BY name LIMIT 3")
    }
    
    @Test
    func LIMITafterHAVING() {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .GROUP_BY(\.name)
            .HAVING("COUNT(*) > 5")
            .LIMIT(10)
        #expect(query.query == "SELECT name FROM users GROUP BY name HAVING COUNT(*) > 5 LIMIT 10")
    }
    
    @Test
    func LIMITafterORDER_BY() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .ORDER_BY(\.name)
            .LIMIT(10)
        #expect(query.query == "SELECT * FROM users ORDER BY name LIMIT 10")
    }
}




//[HAVING ...]
//[ORDER BY ...]

