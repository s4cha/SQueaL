//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct HAVINGTests {
    
    // Covers the deprecated string overload; marked deprecated to silence its warning.
    @available(*, deprecated)
    @Test
    func HAVINGafterSELECT() throws {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .GROUP_BY(\.name)
            .HAVING("COUNT(*) > 500")
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT name FROM users GROUP BY name HAVING COUNT(*) > 500")
        #expect("\(query)" == "SELECT name FROM users GROUP BY name HAVING COUNT(*) > 500")
    }

    @Test
    func HAVING_aggregateComparison_bindsValue() {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .GROUP_BY(\.name)
            .HAVING(COUNT(*) > 500)
        #expect(query.query == "SELECT name FROM users GROUP BY name HAVING COUNT(*) > $1")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 500)
        #expect("\(query)" == "SELECT name FROM users GROUP BY name HAVING COUNT(*) > 500")
    }

    @Test
    func HAVING_aggregateOperators() {
        let base = SQL.SELECT(\.name).FROM(users).GROUP_BY(\.name)
        #expect(base.HAVING(COUNT(*) == 1).query.hasSuffix("HAVING COUNT(*) = $1"))
        #expect(base.HAVING(COUNT(*) != 1).query.hasSuffix("HAVING COUNT(*) != $1"))
        #expect(base.HAVING(COUNT(*) < 1).query.hasSuffix("HAVING COUNT(*) < $1"))
        #expect(base.HAVING(COUNT(*) <= 1).query.hasSuffix("HAVING COUNT(*) <= $1"))
        #expect(base.HAVING(COUNT(*) >= 1).query.hasSuffix("HAVING COUNT(*) >= $1"))
        #expect(base.HAVING(SUM(users.age) > 100).query.hasSuffix("HAVING SUM(users.age) > $1"))
        #expect(base.HAVING(AVG(\UsersTable.age) >= 30.5).query.hasSuffix("HAVING AVG(age) >= $1"))
        #expect(base.HAVING(MIN(users.age) >= 18).query.hasSuffix("HAVING MIN(users.age) >= $1"))
        #expect(base.HAVING(MAX(users.age) < 99).query.hasSuffix("HAVING MAX(users.age) < $1"))
    }

    @Test
    func HAVING_afterWHERE_numbersParametersAfterExistingOnes() {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .WHERE(\.age >= 18)
            .GROUP_BY(\.name)
            .HAVING(COUNT(*) >= 2)
            .ORDER_BY(\.name)
            .LIMIT(10)
        #expect(query.query == "SELECT name FROM users WHERE age >= $1 GROUP BY name HAVING COUNT(*) >= $2 ORDER BY name LIMIT $3")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[0] as? Int == 18)
        #expect(query.parameters[1] as? Int == 2)
    }

    @Test
    func HAVING_SQLExpr_bindsEachPlaceholder() {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .WHERE(\.age >= 18)
            .GROUP_BY(\.name)
            .HAVING(SQLExpr("COUNT(*) >= ? AND SUM(age) > ?", 5, 100))
        #expect(query.query == "SELECT name FROM users WHERE age >= $1 GROUP BY name HAVING COUNT(*) >= $2 AND SUM(age) > $3")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[1] as? Int == 5)
        #expect(query.parameters[2] as? Int == 100)
    }

    @Test
    func HAVING_SQLExpr_keepsUserInputOutOfTheSQL() {
        let malicious = "0; DROP TABLE users;--"
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .GROUP_BY(\.name)
            .HAVING(SQLExpr("MAX(name) = ?", malicious))
        #expect(query.query == "SELECT name FROM users GROUP BY name HAVING MAX(name) = $1")
        #expect(query.parameters[0] as? String == malicious)
    }

    @Test
    func HAVING_asSubquery_keepsRowTypeAndRenumbers() {
        let prolificAuthors = SQL
            .SELECT(\.user_id)
            .FROM(orders)
            .GROUP_BY(\.user_id)
            .HAVING(COUNT(*) >= 5)
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .WHERE(\.age >= 18)
            .AND(\.uuid, IN: prolificAuthors)
        #expect(query.query == "SELECT name FROM users WHERE age >= $1 AND uuid IN (SELECT user_id FROM orders GROUP BY user_id HAVING COUNT(*) >= $2)")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[1] as? Int == 5)
    }
}
