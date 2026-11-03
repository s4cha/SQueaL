//
//  ColumnComparisonTests.swift
//  Squeal
//

import Foundation
import Testing
import Squeal

struct ColumnComparisonTests {

    @Test
    func WHERE_comparesTwoColumns() {
        let query = SQL
            .SELECT(projects.name, departments.name)
            .FROM(projects)
            .JOIN(departments, ON: departments.id == projects.department_id)
            .WHERE(users_departments.department_id == departments.id)
        #expect(query.query == "SELECT projects.name, departments.name FROM projects JOIN departments ON departments.id = projects.department_id WHERE users_departments.department_id = departments.id")
        #expect(query.parameters.isEmpty)
    }

    @Test
    func AND_OR_compareTwoColumns_afterParameters() {
        let userId = UUID()
        let query = SQL
            .SELECT(\.name)
            .FROM(departments)
            .WHERE(\.name == "R&D")
            .AND(users_departments.department_id == departments.id)
            .OR(projects.department_id != departments.id)
            .AND(\.id == userId)
        #expect(query.query == "SELECT name FROM departments WHERE name = $1 AND users_departments.department_id = departments.id OR projects.department_id != departments.id AND id = $2")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[1] as? UUID == userId)
    }

    @Test
    func orderingOperators() {
        let base = SQL.SELECT(\.id).FROM(users)
        #expect(base.WHERE(users.uuid < orders.user_id).query == "SELECT id FROM users WHERE users.uuid < orders.user_id")
        #expect(base.WHERE(users.uuid <= orders.user_id).query == "SELECT id FROM users WHERE users.uuid <= orders.user_id")
        #expect(base.WHERE(users.uuid > orders.user_id).query == "SELECT id FROM users WHERE users.uuid > orders.user_id")
        #expect(base.WHERE(users.uuid >= orders.user_id).query == "SELECT id FROM users WHERE users.uuid >= orders.user_id")
    }

    @Test
    func nullableColumnComparesWithNonNullable() {
        let left = SQL.SELECT(\.id).FROM(departments).WHERE(projects.department_id == departments.id)
        let right = SQL.SELECT(\.id).FROM(departments).WHERE(departments.id == projects.department_id)
        #expect(left.query == "SELECT id FROM departments WHERE projects.department_id = departments.id")
        #expect(right.query == "SELECT id FROM departments WHERE departments.id = projects.department_id")
    }

    @Test
    func JOIN_onNullableForeignKey() {
        let query = SQL
            .SELECT(projects.name, departments.name)
            .FROM(projects)
            .LEFT_JOIN(departments, ON: projects.department_id == departments.id)
        #expect(query.query == "SELECT projects.name, departments.name FROM projects LEFT JOIN departments ON projects.department_id = departments.id")
    }

    @Test
    func JOIN_withOtherOperator() {
        let query = SQL
            .SELECT(users.name)
            .FROM(users)
            .JOIN(orders, ON: orders.user_id != users.uuid)
        #expect(query.query == "SELECT users.name FROM users JOIN orders ON orders.user_id != users.uuid")
    }
}

struct EXISTSTests {

    let userId = UUID()

    var departmentsOfUser: TypedWhereSQLQuery<UsersDepartmentsTable, UUID> {
        SQL.SELECT(\.department_id)
            .FROM(users_departments)
            .WHERE(users_departments.department_id == departments.id)
            .AND(\.user_id == userId)
    }

    @Test
    func WHERE_EXISTS_correlatedSubquery() {
        let query = SQL
            .SELECT(\.name)
            .FROM(departments)
            .WHERE(EXISTS(departmentsOfUser))
        #expect(query.query == "SELECT name FROM departments WHERE EXISTS (SELECT department_id FROM users_departments WHERE users_departments.department_id = departments.id AND user_id = $1)")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? UUID == userId)
    }

    @Test
    func AND_NOT_EXISTS_renumbersParameters() {
        let query = SQL
            .SELECT(\.name)
            .FROM(departments)
            .WHERE(\.name == "R&D")
            .AND(NOT_EXISTS(departmentsOfUser))
            .LIMIT(5)
        #expect(query.query == "SELECT name FROM departments WHERE name = $1 AND NOT EXISTS (SELECT department_id FROM users_departments WHERE users_departments.department_id = departments.id AND user_id = $2) LIMIT $3")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[0] as? String == "R&D")
        #expect(query.parameters[1] as? UUID == userId)
        #expect(query.parameters[2] as? Int == 5)
    }

    @Test
    func OR_EXISTS_and_WHERE_NOT_EXISTS() {
        let or = SQL.SELECT(\.name).FROM(departments).WHERE(\.name == "R&D").OR(EXISTS(departmentsOfUser))
        #expect(or.query == "SELECT name FROM departments WHERE name = $1 OR EXISTS (SELECT department_id FROM users_departments WHERE users_departments.department_id = departments.id AND user_id = $2)")
        let notExists = SQL.SELECT(\.name).FROM(departments).WHERE(NOT_EXISTS(departmentsOfUser))
        #expect(notExists.query == "SELECT name FROM departments WHERE NOT EXISTS (SELECT department_id FROM users_departments WHERE users_departments.department_id = departments.id AND user_id = $1)")
    }

    @Test
    func DELETE_WHERE_NOT_EXISTS() {
        let query = SQL
            .DELETE_FROM(departments)
            .WHERE(NOT_EXISTS(SQL.SELECT(\.department_id).FROM(users_departments).WHERE(users_departments.department_id == departments.id)))
        #expect(query.query == "DELETE FROM departments WHERE NOT EXISTS (SELECT department_id FROM users_departments WHERE users_departments.department_id = departments.id)")
    }
}
