//
//  SelectSubqueryTests.swift
//  Squeal
//

import Foundation
import Testing
import Squeal

struct SelectSubqueryTests {

    let userId = UUID()

    /// One department of the project's department, correlated with the outer `projects` row.
    var departmentName: TypedLimitSQLQuery<DepartmentsTable, String> {
        SQL.SELECT(\.name)
            .FROM(departments)
            .WHERE(departments.id == projects.department_id)
            .LIMIT(1)
    }

    @Test
    func SELECT_correlatedSubquery() {
        let query = SQL
            .SELECT(projects.name, SUBQUERY(departmentName))
            .FROM(projects)
        #expect(query.query == "SELECT projects.name, (SELECT name FROM departments WHERE departments.id = projects.department_id LIMIT $1) FROM projects")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? Int == 1)
    }

    @Test
    func SELECT_severalSubqueries_renumbersParametersInOrder() {
        let userDepartment = SQL
            .SELECT(\.department_id)
            .FROM(users_departments)
            .WHERE(\.user_id == userId)
            .LIMIT(1)
        let query = SQL
            .SELECT(SUBQUERY(departmentName), projects.name, SUBQUERY(userDepartment))
            .FROM(projects)
            .WHERE(projects.name == "Apollo")
            .LIMIT(10)
        #expect(query.query == "SELECT (SELECT name FROM departments WHERE departments.id = projects.department_id LIMIT $1), projects.name, (SELECT department_id FROM users_departments WHERE user_id = $2 LIMIT $3) FROM projects WHERE projects.name = $4 LIMIT $5")
        #expect(query.parameters.count == 5)
        #expect(query.parameters[0] as? Int == 1)
        #expect(query.parameters[1] as? UUID == userId)
        #expect(query.parameters[2] as? Int == 1)
        #expect(query.parameters[3] as? String == "Apollo")
        #expect(query.parameters[4] as? Int == 10)
    }

    @Test
    func SELECT_subqueryWithJOIN() {
        let query = SQL
            .SELECT(projects.name, departments.name, SUBQUERY(departmentName))
            .FROM(projects)
            .LEFT_JOIN(departments, ON: projects.department_id == departments.id)
            .WHERE(projects.name == "Apollo")
        #expect(query.query == "SELECT projects.name, departments.name, (SELECT name FROM departments WHERE departments.id = projects.department_id LIMIT $1) FROM projects LEFT JOIN departments ON projects.department_id = departments.id WHERE projects.name = $2")
        #expect(query.parameters.count == 2)
    }

    @Test
    func TSQL_SELECT_subquery() {
        let query = TSQL<ProjectsTable>
            .SELECT(projects.name, SUBQUERY(departmentName))
            .FROM(projects)
        #expect(query.query == "SELECT projects.name, (SELECT name FROM departments WHERE departments.id = projects.department_id LIMIT $1) FROM projects")
        #expect(query.parameters.count == 1)
    }

    @Test
    func RETURNING_subquery_followsQueryParameters() {
        let projectId = UUID()
        let query = SQL
            .UPDATE(projects, SET: (\.name, "Apollo 2"))
            .WHERE(\.id == projectId)
            .RETURNING(projects.id, SUBQUERY(departmentName))
        #expect(query.query == "UPDATE projects SET name = $1 WHERE id = $2 RETURNING projects.id, (SELECT name FROM departments WHERE departments.id = projects.department_id LIMIT $3)")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[2] as? Int == 1)
    }

    @Test
    func INSERT_RETURNING_subquery() {
        let query = SQL
            .INSERT(INTO: projects, columns: \.id, \.name, VALUES: UUID(), "Apollo")
            .RETURNING(projects.id, SUBQUERY(departmentName))
        #expect(query.query == "INSERT INTO projects (id, name) VALUES ($1, $2) RETURNING projects.id, (SELECT name FROM departments WHERE departments.id = projects.department_id LIMIT $3)")
        #expect(query.parameters.count == 3)
    }

    @Test
    func toString_numbersFromOne() {
        #expect(SUBQUERY(departmentName).toString() == "(SELECT name FROM departments WHERE departments.id = projects.department_id LIMIT $1)")
    }
}
