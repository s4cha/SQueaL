//
//  SubqueryTests.swift
//
//
//  Created by Sacha Durand Saint Omer on 07/10/2026.
//

import Foundation
import Testing
import Squeal


struct SubqueryTests {
    
    let userId = UUID()
    
    var departmentIdsOfUser: TypedWhereSQLQuery<UsersDepartmentsTable, UUID> {
        SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId)
    }
    
    @Test
    func WHERE_IN_subquery() {
        let query = SQL
            .SELECT(\.name)
            .FROM(departments)
            .WHERE(\.id, IN: departmentIdsOfUser)
        #expect(query.query == "SELECT name FROM departments WHERE id IN (SELECT department_id FROM users_departments WHERE user_id = $1)")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? UUID == userId)
    }
    
    @Test
    func AND_IN_subquery_renumbersParameters() {
        let departmentId = UUID()
        let query = SQL
            .SELECT(\.name)
            .FROM(departments)
            .WHERE(\.id == departmentId)
            .AND(\.id, IN: departmentIdsOfUser)
            .LIMIT(1)
        #expect(query.query == "SELECT name FROM departments WHERE id = $1 AND id IN (SELECT department_id FROM users_departments WHERE user_id = $2) LIMIT 1")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? UUID == departmentId)
        #expect(query.parameters[1] as? UUID == userId)
    }
    
    @Test
    func IN_subquery_onOptionalColumn() {
        let query = SQL
            .SELECT(\.id)
            .FROM(projects)
            .WHERE(\.name == "Squeal")
            .AND(\.department_id, IN: departmentIdsOfUser)
        #expect(query.query == "SELECT id FROM projects WHERE name = $1 AND department_id IN (SELECT department_id FROM users_departments WHERE user_id = $2)")
        #expect(query.parameters.count == 2)
    }
    
    @Test
    func nested_IN_subqueries() {
        let projectId = UUID()
        let departmentIdsOfUserNamed = SQL
            .SELECT(\.id)
            .FROM(departments)
            .WHERE(\.name == "R&D")
            .AND(\.id, IN: departmentIdsOfUser)
        let query = SQL
            .DELETE(FROM: projects)
            .WHERE(\.id == projectId)
            .AND(\.department_id, IN: departmentIdsOfUserNamed)
            .RETURNING(\.id)
        #expect(query.query == "DELETE FROM projects WHERE id = $1 AND department_id IN (SELECT id FROM departments WHERE name = $2 AND id IN (SELECT department_id FROM users_departments WHERE user_id = $3)) RETURNING id")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[0] as? UUID == projectId)
        #expect(query.parameters[1] as? String == "R&D")
        #expect(query.parameters[2] as? UUID == userId)
    }
    
    @Test
    func UPDATE_WHERE_AND_IN_subquery() {
        let projectId = UUID()
        let query = SQL
            .UPDATE(projects, SET: (\.department_id, nil))
            .WHERE(\.id == projectId)
            .AND(\.department_id, IN: departmentIdsOfUser)
        #expect(query.query == "UPDATE projects SET department_id = $1 WHERE id = $2 AND department_id IN (SELECT department_id FROM users_departments WHERE user_id = $3)")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[2] as? UUID == userId)
    }
    
    @Test
    func UPDATE_SET_subquery_onOptionalColumn() {
        let projectId = UUID()
        let query = SQL
            .UPDATE(projects, SET: (\.department_id, SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId).ORDER_BY(\.department_id, .ASC).LIMIT(1)))
            .WHERE(\.id == projectId)
        #expect(query.query == "UPDATE projects SET department_id = (SELECT department_id FROM users_departments WHERE user_id = $1 ORDER BY department_id ASC LIMIT 1) WHERE id = $2")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? UUID == userId)
        #expect(query.parameters[1] as? UUID == projectId)
    }
    
    @Test
    func UPDATE_SET_subquery() {
        let query = SQL
            .UPDATE(departments, SET: (\.id, SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId).LIMIT(1)))
            .WHERE(\.name == "R&D")
        #expect(query.query == "UPDATE departments SET id = (SELECT department_id FROM users_departments WHERE user_id = $1 LIMIT 1) WHERE name = $2")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[1] as? String == "R&D")
    }
    
    @Test
    func INSERT_VALUES_subquery_RETURNING() {
        let query = SQL
            .INSERT(INTO: projects,
                    columns: \.department_id, \.name,
                    VALUES: SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId).LIMIT(1),
                            "Squeal")
            .RETURNING(projects.id, RawSQL("upper(name)"))
        #expect(query.query == "INSERT INTO projects (department_id, name) VALUES ((SELECT department_id FROM users_departments WHERE user_id = $1 LIMIT 1), $2) RETURNING projects.id, upper(name)")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? UUID == userId)
        #expect(query.parameters[1] as? String == "Squeal")
    }
    
    @Test
    func INSERT_VALUES_subquery_betweenValues_renumbersParameters() {
        let projectId = UUID()
        let query = SQL
            .INSERT(INTO: projects,
                    columns: \.id, \.department_id, \.name,
                    VALUES: projectId,
                            SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId).LIMIT(1),
                            SQLExpr("lower(?)", "SQUEAL"))
        #expect(query.query == "INSERT INTO projects (id, department_id, name) VALUES ($1, (SELECT department_id FROM users_departments WHERE user_id = $2 LIMIT 1), lower($3))")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[0] as? UUID == projectId)
        #expect(query.parameters[1] as? UUID == userId)
        #expect(query.parameters[2] as? String == "SQUEAL")
    }
    
    @available(macOS 14.0.0, *)
    @Test
    func INSERT_lone_VALUES_subquery() {
        let query = SQL
            .INSERT(INTO: projects, columns: \.name, \.department_id)
            .VALUES("Squeal", SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId).LIMIT(1))
        #expect(query.query == "INSERT INTO projects (name, department_id) VALUES ($1, (SELECT department_id FROM users_departments WHERE user_id = $2 LIMIT 1))")
        #expect(query.parameters.count == 2)
    }
    
    @Test
    func UPDATE_SET_mixed_withSubquery() {
        let query = SQL
            .UPDATE(projects, SET: (\.name, "Squeal"),
                                   (\.department_id, SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId).LIMIT(1)))
            .WHERE(\.name == "Old")
        #expect(query.query == "UPDATE projects SET name = $1, department_id = (SELECT department_id FROM users_departments WHERE user_id = $2 LIMIT 1) WHERE name = $3")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[2] as? String == "Old")
    }
}
