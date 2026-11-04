//
//  TypedValuesTests.swift
//  Squeal
//

import Foundation
import Testing
import Squeal

enum ProjectStatus: String, Codable, SQLValue {
    case active, archived
}

@Table(schema: "typed_projects")
struct TypedProject {
    let id: UUID
    let name: String
    let status: ProjectStatus
    let budget: Double
    let department_id: UUID?
    let updated_at: Date
    let note: String?
}

/// `INSERT … VALUES` and `UPDATE … SET` values checked against their columns. Mismatches
/// don't compile, or warn through the deprecated overloads, so these only cover what compiles.
struct TypedValuesTests {

    let typedProjects = TypedProjectTable()
    let id = UUID()

    @Test
    func INSERT_plainValues_implicitEnumMember_andIntegerLiteralForDouble() {
        let query = SQL.INSERT(INTO: typedProjects, columns: \.id, \.status, \.budget, VALUES: id, .active, 100)
        #expect(query.query == "INSERT INTO typed_projects (id, status, budget) VALUES ($1, $2, $3)")
        #expect(query.parameters[1] as? ProjectStatus == .active)
        #expect(query.parameters[2] as? Double == 100)
    }

    @Test
    func INSERT_expressionRow() {
        let query = SQL.INSERT(INTO: typedProjects,
                               columns: \.id, \.name, \.status, \.updated_at,
                               VALUES: SQLExpr("gen_random_uuid()"), SQLExpr("trim(?)", " Squeal "), ProjectStatus.active, NOW())
        #expect(query.query == "INSERT INTO typed_projects (id, name, status, updated_at) VALUES (gen_random_uuid(), trim($1), $2, now())")
        #expect(query.parameters.count == 2)
    }

    @Test
    func UPDATE_expressionRow_withCOALESCE_andNil() {
        let note: String? = nil
        let query = SQL
            .UPDATE(typedProjects, SET: (\.note, COALESCE(note, typedProjects.note)),
                                        (\.budget, SQLExpr("budget * ?", 1.1)),
                                        (\.updated_at, NOW() - INTERVAL(1, .DAY)))
            .WHERE(\.id == id)
        #expect(query.query == "UPDATE typed_projects SET note = COALESCE($1, typed_projects.note), budget = budget * $2, updated_at = now() - $3::interval WHERE id = $4")
        #expect(query.parameters.count == 4)
    }

    @Test
    func UPDATE_plainRow_withNil() {
        let query = SQL.UPDATE(typedProjects, SET: (\.department_id, nil)).WHERE(\.id == id)
        #expect(query.query == "UPDATE typed_projects SET department_id = $1 WHERE id = $2")
        #expect(query.parameters[0] == nil)
    }

    @Test
    func UPDATE_storedExpression_withItsType() {
        let doubled = SQLExpr<Double>("budget * ?", 2)
        let query = SQL.UPDATE(typedProjects, SET: (\.budget, doubled), (\.updated_at, NOW())).WHERE(\.id == id)
        #expect(query.query == "UPDATE typed_projects SET budget = budget * $1, updated_at = now() WHERE id = $2")
    }

    @Test
    func UPDATE_inlineSubquery_typedByItsColumn() {
        let userId = UUID()
        let query = SQL
            .UPDATE(typedProjects, SET: (\.department_id, SQL.SELECT(\.department_id).FROM(users_departments).WHERE(\.user_id == userId).LIMIT(1)),
                                        (\.updated_at, NOW()))
            .WHERE(\.id == id)
        #expect(query.query == "UPDATE typed_projects SET department_id = (SELECT department_id FROM users_departments WHERE user_id = $1 LIMIT $2), updated_at = now() WHERE id = $3")
        #expect(query.parameters.count == 3)
    }

    @available(macOS 14.0.0, *)
    @Test
    func INSERT_severalRows_withExpressions() {
        var insert = SQL.INSERT(INTO: typedProjects, columns: \.id, \.updated_at)
        insert.ADDVALUES(id, NOW())
        let query = insert.VALUES(SQLExpr("gen_random_uuid()"), NOW())
        #expect(query.query == "INSERT INTO typed_projects (id, updated_at) VALUES ($1, now()), (gen_random_uuid(), now())")
    }

    @Test
    func SQLExpr_inConditions_isUntyped() {
        let condition = SQLExpr("(budget > ? OR note IS NULL)", 1000)
        let query = SQL.SELECT(\.id).FROM(typedProjects).WHERE(condition).AND(SQLExpr("status = ?", "active"))
        #expect(query.query == "SELECT id FROM typed_projects WHERE (budget > $1 OR note IS NULL) AND status = $2")
    }

    @available(*, deprecated, message: "Exercises the deprecated untyped overloads on purpose.")
    @Test
    func untypedValues_stillWork_throughTheDeprecatedOverloads() {
        let query = SQL.UPDATE(typedProjects, SET: (\.name, RawSQL("initcap(name)")), (\.budget, 2 as Any)).WHERE(\.id == id)
        #expect(query.query == "UPDATE typed_projects SET name = initcap(name), budget = $1 WHERE id = $2")
    }
}
