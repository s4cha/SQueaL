//
//  GlobalStatementsTests.swift
//  Squeal
//

import Foundation
import Testing
import Squeal

/// `INSERT`, `UPDATE` and `DELETE` without the `SQL.` prefix render the same as their `SQL.` twins.
struct GlobalStatementsTests {

    let id = UUID()

    @Test
    func INSERT_forms() {
        #expect(INSERT(INTO: departments, columns: \.id, \.name, VALUES: id, "R&D").query
                == SQL.INSERT(INTO: departments, columns: \.id, \.name, VALUES: id, "R&D").query)
        #expect(INSERT(INTO: departments, columns: \.id, \.name, VALUES: SQLExpr("gen_random_uuid()"), SQLExpr("trim(?)", " R&D ")).query
                == "INSERT INTO departments (id, name) VALUES (gen_random_uuid(), trim($1))")
        #expect(INSERT(INTO: departments, columns: \.id, \.name, addValuesFrom: ["A", "B"], mapValues: { (id, $0) }).query
                == "INSERT INTO departments (id, name) VALUES ($1, $2), ($3, $4)")
        #expect(INSERT(INTO: departments, columns: \.id, \.name, SELECT: id, "R&D").WHERE(NOT_EXISTS(SELECT(1).FROM(departments).WHERE(departments.id == id))).ON_CONFLICT(DO: .NOTHING).query
                == "INSERT INTO departments (id, name) SELECT $1, $2 WHERE NOT EXISTS (SELECT 1 FROM departments WHERE departments.id = $3) ON CONFLICT DO NOTHING")
        #expect(INSERT(INTO: users_departments, columns: \.department_id, \.user_id, SELECT: SELECT(\.department_id, \.user_id).FROM(users_departments)).query
                == "INSERT INTO users_departments (department_id, user_id) SELECT department_id, user_id FROM users_departments")
    }

    @available(macOS 14.0.0, *)
    @Test
    func INSERT_severalRows() {
        var insert = INSERT(INTO: departments, columns: \.id, \.name)
        insert.ADDVALUES(id, "R&D")
        #expect(insert.VALUES(id, "Sales").query == "INSERT INTO departments (id, name) VALUES ($1, $2), ($3, $4)")
    }

    @Test
    func UPDATE_forms() {
        #expect(UPDATE(departments, SET: (\.name, "R&D")).WHERE(\.id == id).query
                == SQL.UPDATE(departments, SET: (\.name, "R&D")).WHERE(\.id == id).query)
        let name: String? = nil
        #expect(UPDATE(departments, SET: (\.name, COALESCE(name, departments.name))).WHERE(\.id == id).RETURNING(\.id).query
                == "UPDATE departments SET name = COALESCE($1, departments.name) WHERE id = $2 RETURNING id")
    }

    @Test
    func DELETE_forms() {
        #expect(DELETE_FROM(departments).WHERE(\.id == id).query == SQL.DELETE_FROM(departments).WHERE(\.id == id).query)
        #expect(DELETE(FROM: departments).WHERE(\.id == id).RETURNING(\.id).query == "DELETE FROM departments WHERE id = $1 RETURNING id")
    }

    @available(*, deprecated, message: "Exercises the deprecated untyped overloads on purpose.")
    @Test
    func untypedValues_throughTheDeprecatedGlobals() {
        #expect(UPDATE(departments, SET: (\.name, RawSQL("initcap(name)"))).WHERE(\.id == id).query == "UPDATE departments SET name = initcap(name) WHERE id = $1")
        #expect(INSERT(INTO: departments, columns: \.id, \.name, VALUES: id, RawSQL("'x'")).query == "INSERT INTO departments (id, name) VALUES ($1, 'x')")
    }
}
