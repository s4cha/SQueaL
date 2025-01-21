//
//  ORDER_BYTests.swift
//
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct ORDER_BYTests {
    
    @Test
    func ORDER_BYafterSELECT() {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id, name FROM users ORDER BY name")
        #expect("\(query)" == "SELECT id, name FROM users ORDER BY name")
    }
    
    @Test
    func ORDER_BY_ASC_afterSELECT() {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name, .ASC)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id, name FROM users ORDER BY name ASC")
        #expect("\(query)" == "SELECT id, name FROM users ORDER BY name ASC")
    }
    
    @Test
    func multipleORDER_BY_afterSELECT() {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY((\.id, .ASC), (\.name, .DESC))
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id, name FROM users ORDER BY id ASC, name DESC")
        #expect("\(query)" == "SELECT id, name FROM users ORDER BY id ASC, name DESC")
    }
    
    @Test
    func ORDER_BY_ASC2_afterSELECT() {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name).ASC
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id, name FROM users ORDER BY name ASC")
        #expect("\(query)" == "SELECT id, name FROM users ORDER BY name ASC")
    }
    
    @Test
    func ORDER_BY_DESC_afterSELECT() {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name, .DESC)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id, name FROM users ORDER BY name DESC")
        #expect("\(query)" == "SELECT id, name FROM users ORDER BY name DESC")
    }
    
    @Test
    func ORDER_BY_DESC2_afterSELECT() {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .ORDER_BY(\.name).DESC
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id, name FROM users ORDER BY name DESC")
        #expect("\(query)" == "SELECT id, name FROM users ORDER BY name DESC")
    }
    
    @Test
    func ORDER_BYafterWHERE() {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .WHERE(\.id > 12)
            .ORDER_BY(\.name)
        #expect(query.parameters.count == 1)
        #expect(query.query == "SELECT id, name FROM users WHERE id > $1 ORDER BY name")
        #expect("\(query)" == "SELECT id, name FROM users WHERE id > 12 ORDER BY name")
    }
}
