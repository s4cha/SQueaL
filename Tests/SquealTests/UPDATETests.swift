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
    func UPDATEwithoutWHERE_isNotARunnableQuery() {
        // `let query: SQLQuery = SQL.UPDATE(users, SET: …)` doesn't compile: without WHERE it can't run.
        let query = SQL
            .UPDATE(users, SET: (\.name, "john"))
        #expect(!((query as Any) is any SQLQuery))
        #expect(query.parameters.count == 1)
        #expect(query.query == "UPDATE users SET name = $1")
        #expect("\(query)" == "UPDATE users SET name = 'john'")
        let withExpressions = SQL.UPDATE(users, SET: (\.name, SQLExpr("upper(name)")))
        #expect(!((withExpressions as Any) is any SQLQuery))
    }

    @Test
    func UPDATEeveryRowOnPurpose() {
        let query = SQL.UPDATE(users, SET: (\.age, 0)).WHERE(SQLExpr("true"))
        #expect(query.query == "UPDATE users SET age = $1 WHERE true")
        #expect(query.parameters.count == 1)
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
    
    @Test
    func UPDATEwithRETURNING() {
        let query = SQL
            .UPDATE(users, SET: (\.name, "john"))
            .WHERE(\.id == 12)
            .RETURNING(\.id)
        #expect(query.query == "UPDATE users SET name = $1 WHERE id = $2 RETURNING id")
    }
    
    @Test
    func UPDATEwithRETURNINGGmultipleColumns() {
        let query = SQL
            .UPDATE(users, SET: (\.name, "john"))
            .WHERE(\.id == 1)
            .RETURNING(\.id, \.name)
        #expect(query.query == "UPDATE users SET name = $1 WHERE id = $2 RETURNING id, name")
    }
    
    @Test
    func UPDATEwithRETURNINGstar() {
        let query = SQL
            .UPDATE(users, SET: (\.name, "john"))
            .WHERE(\.id == 12)
            .RETURNING(*)
        #expect(query.query == "UPDATE users SET name = $1 WHERE id = $2 RETURNING *")
    }
}

struct UPDATE_ExpressionsTests {
    
    @Test
    func UPDATE_SET_mixedValuesAndExpressions() {
        let name: String? = nil
        let query = SQL
            .UPDATE(users, SET: (\.name, SQLExpr("COALESCE(?, name)", name)),
                                (\.age, 42),
                                (\.uuid, RawSQL("gen_random_uuid()")))
            .WHERE(\.id == 7)
        #expect(query.query == "UPDATE users SET name = COALESCE($1, name), age = $2, uuid = gen_random_uuid() WHERE id = $3")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[0] == nil)
        #expect(query.parameters[1] as? Int == 42)
        #expect(query.parameters[2] as? Int == 7)
    }
    
    @Test
    func UPDATE_SET_plainValues_stillBindsEachValue() {
        let query = SQL
            .UPDATE(users, SET: (\.name, "Alice"), (\.age, 30))
            .WHERE(\.id == 1)
        #expect(query.query == "UPDATE users SET name = $1, age = $2 WHERE id = $3")
        #expect(query.parameters.count == 3)
    }
    
    @Test
    func UPDATE_WHERE_RETURNING_columnsAndExpressions() {
        let query = SQL
            .UPDATE(users, SET: (\.name, SQLExpr("upper(?)", "alice")))
            .WHERE(\.id == 1)
            .RETURNING(users.id, RawSQL("length(name)"), users.name)
        #expect(query.query == "UPDATE users SET name = upper($1) WHERE id = $2 RETURNING users.id, length(name), users.name")
        #expect(query.parameters.count == 2)
    }
    
    @Test
    func INSERT_RETURNING_columnsAndExpressions() {
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name, VALUES: 1, "Alice")
            .RETURNING(users.id, RawSQL("upper(name)"))
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) RETURNING users.id, upper(name)")
    }
    
    @Test
    func INSERT_ON_CONFLICT_RETURNING_columnsAndExpressions() {
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.name, VALUES: 1, "Alice")
            .ON_CONFLICT(\.id, DO: .NOTHING)
            .RETURNING(users.id, RawSQL("upper(name)"))
        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT (id) DO NOTHING RETURNING users.id, upper(name)")
    }
}
