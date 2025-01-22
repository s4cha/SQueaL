//
//  OffsetTests.swift
//
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct OffsetTests {
        
    @Test
    func OFFSETAfterFROM() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .OFFSET(20)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT * FROM users OFFSET 20")
        #expect("\(query)" == "SELECT * FROM users OFFSET 20")
    }
    
    @Test
    func OFFSETAfterWHERE() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 34)
            .OFFSET(12)
        #expect(query.parameters.count == 1)
        #expect(query.query == "SELECT * FROM users WHERE id = $1 OFFSET 12")
        #expect("\(query)" == "SELECT * FROM users WHERE id = 34 OFFSET 12")
    }
    
    @Test
    func OFFSETafterAND() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\UsersTable.name == "jack")
            .OFFSET(3)
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.parameters[1] as? String == "jack")
        #expect(query.query == "SELECT * FROM users WHERE id = $1 AND name = $2 OFFSET 3")
        #expect("\(query)" == "SELECT * FROM users WHERE id = 1 AND name = 'jack' OFFSET 3")
    }
    
    @Test
    func OFFSETAfterGROUP_BY() {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .WHERE(\.id == 1)
            .AND(\.name == "jack")
            .GROUP_BY(\.name)
            .OFFSET(34)
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.parameters[1] as? String == "jack")
        #expect(query.query == "SELECT name FROM users WHERE id = $1 AND name = $2 GROUP BY name OFFSET 34")
        #expect("\(query)" == "SELECT name FROM users WHERE id = 1 AND name = 'jack' GROUP BY name OFFSET 34")
    }
    
    @Test
    func OFFSETAfterLIMIT() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .LIMIT(10)
            .OFFSET(20)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT * FROM users LIMIT 10 OFFSET 20")
        #expect("\(query)" == "SELECT * FROM users LIMIT 10 OFFSET 20")
    }
}
