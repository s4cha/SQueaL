//
//  RawSQLTests.swift
//
//
//  Created by Sacha Durand Saint Omer on 07/03/2026.
//

import Testing
import Squeal


struct RawSQLTests {
    
    @Test
    func RawSQLExpression() {
        let query = SQL
            .SELECT(RawSQL("ST_X(location::geometry) AS lng"))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT ST_X(location::geometry) AS lng FROM users")
        #expect("\(query)" == "SELECT ST_X(location::geometry) AS lng FROM users")
    }
    
    @Test
    func RawSQLWithOtherFields() {
        let query = SQL
            .SELECT(users.id, RawSQL("NOW() AS current_time"))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT users.id, NOW() AS current_time FROM users")
        #expect("\(query)" == "SELECT users.id, NOW() AS current_time FROM users")
    }
    
    @Test
    func RawSQLMultiple() {
        let query = SQL
            .SELECT(
                RawSQL("ST_X(location::geometry) AS lng"),
                RawSQL("ST_Y(location::geometry) AS lat")
            )
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT ST_X(location::geometry) AS lng, ST_Y(location::geometry) AS lat FROM users")
        #expect("\(query)" == "SELECT ST_X(location::geometry) AS lng, ST_Y(location::geometry) AS lat FROM users")
    }
}
