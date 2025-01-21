//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct HAVINGTests {
    
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
}
