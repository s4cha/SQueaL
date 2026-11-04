//
//  INSERT_SELECTTests.swift
//  Squeal
//

import Foundation
import Testing
import Squeal

struct INSERT_SELECTTests {

    let departmentId = UUID()
    let userId = UUID()

    @Test
    func INSERT_SELECT_values() {
        let query = SQL.INSERT(INTO: users_departments, columns: \.department_id, \.user_id, SELECT: departmentId, userId)
        #expect(query.query == "INSERT INTO users_departments (department_id, user_id) SELECT $1, $2")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? UUID == departmentId)
        #expect(query.parameters[1] as? UUID == userId)
    }

    @Test
    func INSERT_SELECT_values_WHERE_EXISTS_ON_CONFLICT() {
        let query = SQL
            .INSERT(INTO: users_departments, columns: \.department_id, \.user_id, SELECT: departmentId, userId)
            .WHERE(EXISTS(SQL.SELECT(\.id).FROM(departments).WHERE(departments.id == departmentId).AND(departments.name != "Archive")))
            .ON_CONFLICT(DO: .NOTHING)
        #expect(query.query == "INSERT INTO users_departments (department_id, user_id) SELECT $1, $2 WHERE EXISTS (SELECT id FROM departments WHERE departments.id = $3 AND departments.name != $4) ON CONFLICT DO NOTHING")
        #expect(query.parameters.count == 4)
        #expect(query.parameters[2] as? UUID == departmentId)
        #expect(query.parameters[3] as? String == "Archive")
    }

    @Test
    func INSERT_SELECT_values_WHERE_AND_OR_RETURNING() {
        let query = SQL
            .INSERT(INTO: users_departments, columns: \.department_id, \.user_id, SELECT: departmentId, userId)
            .WHERE(NOT_EXISTS(SQL.SELECT(\.user_id).FROM(users_departments).WHERE(\.user_id == userId)))
            .AND(SQLExpr("? > 0", 1))
            .OR(departments.name == "Open")
            .RETURNING(\.user_id)
        #expect(query.query == "INSERT INTO users_departments (department_id, user_id) SELECT $1, $2 WHERE NOT EXISTS (SELECT user_id FROM users_departments WHERE user_id = $3) AND $4 > 0 OR departments.name = $5 RETURNING user_id")
        #expect(query.parameters.count == 5)
    }

    @Test
    func INSERT_SELECT_query() {
        let query = SQL.INSERT(INTO: users_departments, columns: \.department_id, \.user_id,
                               SELECT: SQL.SELECT(\.department_id, \.user_id).FROM(users_departments).WHERE(\.user_id == userId))
        #expect(query.query == "INSERT INTO users_departments (department_id, user_id) SELECT department_id, user_id FROM users_departments WHERE user_id = $1")
        #expect(query.parameters.count == 1)
    }

    @Test
    func INSERT_SELECT_query_ON_CONFLICT() {
        let query = SQL
            .INSERT(INTO: projects, columns: \.id, SELECT: SQL.SELECT(\.id).FROM(departments).WHERE(\.name == "R&D").LIMIT(1))
            .ON_CONFLICT(DO: .NOTHING)
        #expect(query.query == "INSERT INTO projects (id) SELECT id FROM departments WHERE name = $1 LIMIT $2 ON CONFLICT DO NOTHING")
        #expect(query.parameters.count == 2)
    }

    @Test
    func SELECT_values_WHERE() {
        let query = SQL.SELECT(departmentId, userId)
            .WHERE(NOT_EXISTS(SQL.SELECT(\.user_id).FROM(users_departments).WHERE(users_departments.user_id == userId)))
        #expect(query.query == "SELECT $1, $2 WHERE NOT EXISTS (SELECT user_id FROM users_departments WHERE users_departments.user_id = $3)")
        #expect(query.parameters.count == 3)
    }

    @Test
    func SELECT_values_asSubquery() {
        let query = SQL.SELECT(\.name).FROM(departments).WHERE(\.id, IN: SQL.SELECT(departmentId))
        #expect(query.query == "SELECT name FROM departments WHERE id IN (SELECT $1)")
        #expect(query.parameters[0] as? UUID == departmentId)
    }
}
