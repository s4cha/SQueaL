//
//  GlobalSELECTTests.swift
//  Squeal
//

import Foundation
import Testing
import Squeal

/// `SELECT` without the `SQL.` prefix renders the same as `SQL.SELECT`.
struct GlobalSELECTTests {

    let userId = UUID()

    @Test
    func subqueries() {
        let query = SQL.SELECT(\.name).FROM(departments)
            .WHERE(\.id, IN: SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId))
            .AND(EXISTS(SELECT(1).FROM(projects).WHERE(projects.department_id == departments.id)))
        #expect(query.query == "SELECT name FROM departments WHERE id IN (SELECT department_id FROM users_departments WHERE user_id = $1) AND EXISTS (SELECT 1 FROM projects WHERE projects.department_id = departments.id)")
        #expect(query.parameters.count == 1)
    }

    @Test
    func everyForm_matchesSQLSELECT() {
        let id = UUID()
        #expect(SELECT(*).FROM(departments).query == SQL.SELECT(*).FROM(departments).query)
        #expect(SELECT(\.id, \.name).FROM(departments).query == SQL.SELECT(\.id, \.name).FROM(departments).query)
        #expect(SELECT(departments.id, COUNT(*)).FROM(departments).query == SQL.SELECT(departments.id, COUNT(*)).FROM(departments).query)
        #expect(SELECT_DISTINCT(\.name).FROM(departments).query == SQL.SELECT_DISTINCT(\.name).FROM(departments).query)
        #expect(SELECT((\DepartmentsTable.id, AS: "department")).FROM(departments).query == "SELECT id AS department FROM departments")
        #expect(SELECT_DISTINCT((\DepartmentsTable.name, AS: "n")).FROM(departments).query == "SELECT DISTINCT name AS n FROM departments")
        #expect(SELECT(1).query == "SELECT 1")
        #expect(SELECT(id, userId).query == "SELECT $1, $2")
    }

    @Test
    func topLevelQuery_withoutPrefix() {
        let query = SELECT(\.name).FROM(departments).WHERE(\.name == "R&D").LIMIT(1)
        #expect(query.query == "SELECT name FROM departments WHERE name = $1 LIMIT $2")
    }
}
