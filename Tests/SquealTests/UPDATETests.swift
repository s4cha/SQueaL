//
//  UPDATETests.swift
//
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct UPDATETests {
    
    @Test
    func UPDATEwhere() {
        let query = SQL
            .UPDATE(users, SET: (\.name, "john"))
            .WHERE(\.id == 12)
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? String == "john")
        #expect(query.parameters[1] as? Int == 12)
        #expect(query.query == "UPDATE users SET name = $1 WHERE id = $2")
        #expect("\(query)" == "UPDATE users SET name = 'john' WHERE id = 12")
    }
    
    @Test
    func multipleUpdatesTyped() {
        let query = SQL
            .UPDATE(users,
                    SET:
                        (\.name, "john"),
                        (\.age, 42)
            )
            .WHERE(\.id == 12)
        #expect(query.parameters.count == 3)
        #expect(query.parameters[0] as? String == "john")
        #expect(query.parameters[1] as? Int == 42)
        #expect(query.query == "UPDATE users SET name = $1, age = $2 WHERE id = $3")
        #expect("\(query)" == "UPDATE users SET name = 'john', age = 42 WHERE id = 12")
    }
    
    @Test
    func UPDATEwithoutWHERE() {
        let query = SQL
            .UPDATE(users, SET: (\.name, "john"))
        #expect(query.parameters.count == 1)
        #expect(query.query == "UPDATE users SET name = $1")
        #expect("\(query)" == "UPDATE users SET name = 'john'")
    }

    @Test
    func UPDATEmultipleColumnsANDwhere() {
        let query = SQL
            .UPDATE(users,
                    SET:
                        (\.name, "john"),
                        (\.age, 42)
            )
            .WHERE(\.id == 12)
            .AND(\.name == "old_name")
        #expect(query.parameters.count == 4)
        #expect(query.query == "UPDATE users SET name = $1, age = $2 WHERE id = $3 AND name = $4")
    }
}
