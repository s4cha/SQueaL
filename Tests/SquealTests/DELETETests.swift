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
}
