//
//  TypeCheckingTests.swift
//  Squeal
//

import Foundation
import Testing
import Squeal

/// Query shapes that used to take seconds to type-check, or failed with "the compiler is unable
/// to type-check this expression in reasonable time": a comparison with a literal and an inline
/// subquery with its own comparison, in one expression. Each must stay a single expression.
///
/// To measure, build the tests with
/// `-Xswiftc -Xfrontend -Xswiftc -warn-long-expression-type-checking=100`.
struct TypeCheckingTests {

    let userId = UUID()

    @Test
    func SELECT_literalComparison_AND_IN_inlineSubquery() {
        let query = SQL.SELECT(\.name).FROM(projects)
            .WHERE(\.name == "Apollo")
            .AND(\.department_id, IN: SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId))
        #expect(query.query == "SELECT name FROM projects WHERE name = $1 AND department_id IN (SELECT department_id FROM users_departments WHERE user_id = $2)")
        #expect(query.parameters.count == 2)
    }

    @Test
    func SELECT_literalComparison_AND_IN_inlineSubquery_nonOptionalColumn() {
        let query = SQL.SELECT(\.name).FROM(projects)
            .WHERE(\.name == "Apollo")
            .AND(\.id, IN: SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId))
        #expect(query.query == "SELECT name FROM projects WHERE name = $1 AND id IN (SELECT department_id FROM users_departments WHERE user_id = $2)")
    }

    @Test
    func UPDATE_setNil_AND_IN_inlineSubquery() {
        let projectId = UUID()
        let query = SQL
            .UPDATE(projects, SET: (\.department_id, nil))
            .WHERE(\.id == projectId)
            .AND(\.department_id, IN: SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId))
        #expect(query.query == "UPDATE projects SET department_id = $1 WHERE id = $2 AND department_id IN (SELECT department_id FROM users_departments WHERE user_id = $3)")
    }

    @Test
    func SELECT_literalComparison_AND_EXISTS_inlineSubquery() {
        let query = SQL.SELECT(\.name).FROM(departments)
            .WHERE(\.name == "R&D")
            .AND(EXISTS(SQL.SELECT(\.department_id).FROM(users_departments).WHERE(users_departments.department_id == departments.id).AND(\.user_id == userId)))
        #expect(query.query == "SELECT name FROM departments WHERE name = $1 AND EXISTS (SELECT department_id FROM users_departments WHERE users_departments.department_id = departments.id AND user_id = $2)")
    }

    @Test
    func SELECT_mixedConditions_inOneExpression() {
        let query = SQL.SELECT(projects.name).FROM(projects)
            .JOIN(departments, ON: departments.id == projects.department_id)
            .WHERE(\.name == "Apollo")
            .AND(departments.name != "Archive")
            .OR(projects.name == "Gemini")
            .AND(\.department_id, IN: SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId))
        #expect(query.query == "SELECT projects.name FROM projects JOIN departments ON departments.id = projects.department_id WHERE name = $1 AND departments.name != $2 OR projects.name = $3 AND department_id IN (SELECT department_id FROM users_departments WHERE user_id = $4)")
    }
}
