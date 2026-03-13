//
//  SQLCoverageTests.swift
//
//  Comprehensive test suite validating common SQL query patterns.
//
//  Organized in two sections:
//  1. Untested clause combinations (should compile & pass with current API)
//  2. Missing SQL syntax (commented out — needs implementation to compile)
//

import Testing
import Squeal
import Foundation


struct ClauseCombinationTests {

    @Test
    func fullSELECTpipeline() {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
            .WHERE(\.age > 18)
            .AND(\.name == "Alice")
            .ORDER_BY(\.name, .ASC)
            .LIMIT(25)
            .OFFSET(50)
        #expect(query.query == "SELECT id, name FROM users WHERE age > $1 AND name = $2 ORDER BY name ASC LIMIT 25 OFFSET 50")
    }

    @Test
    func paginatedQuery() {
        let page = 3
        let pageSize = 20
        let query = SQL
            .SELECT(*)
            .FROM(users)
            .ORDER_BY(\.id, .ASC)
            .LIMIT(pageSize)
            .OFFSET((page - 1) * pageSize)
        #expect(query.query == "SELECT * FROM users ORDER BY id ASC LIMIT 20 OFFSET 40")
    }

    @Test
    func JOINwithWHEREandORDER_BY() {
        let query = TSQL
            .SELECT((\.name, AS: "username"))
            .FROM(users)
            .JOIN(orders, ON: users.uuid == orders.user_id)
            .WHERE(\.name == "Alice")
            .ORDER_BY(\.name, .DESC)
            .LIMIT(10)
        #expect(query.query == "SELECT name AS username FROM users JOIN orders ON users.uuid = orders.user_id WHERE name = $1 ORDER BY name DESC LIMIT 10")
    }

    @Test
    func GROUPBYwithHAVINGandLIMIT() {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .WHERE(\.age > 18)
            .GROUP_BY(\.name)
            .HAVING("COUNT(*) > 1")
            .LIMIT(50)
        #expect(query.query == "SELECT name FROM users WHERE age > $1 GROUP BY name HAVING COUNT(*) > 1 LIMIT 50")
    }

    // MARK: - WHERE LIKE variants
}


// =============================================================================
// MARK: - 2. Missing SQL Syntax (commented out — needs implementation)
// =============================================================================
//
// Each section below describes a common SQL feature not yet supported.
// Uncomment the tests once the corresponding API is implemented.
//



// MARK: - Aggregate Functions: SUM, AVG, MIN, MAX

struct AggregateTests {

    @Test
    func SELECTsum() {
        let query = SQL
            .SELECT(SUM(users.age))
            .FROM(users)
        #expect(query.query == "SELECT SUM(users.age) FROM users")
    }

    @Test
    func SELECTavg() {
        let query = SQL
            .SELECT(AVG(users.age))
            .FROM(users)
        #expect(query.query == "SELECT AVG(users.age) FROM users")
    }

    @Test
    func SELECTmin() {
        let query = SQL
            .SELECT(MIN(users.age))
            .FROM(users)
        #expect(query.query == "SELECT MIN(users.age) FROM users")
    }

    @Test
    func SELECTmax() {
        let query = SQL
            .SELECT(MAX(users.age))
            .FROM(users)
        #expect(query.query == "SELECT MAX(users.age) FROM users")
    }

    @Test
    func SELECTmultipleAggregates() {
        let query = SQL
            .SELECT(MIN(users.age), MAX(users.age), AVG(users.age))
            .FROM(users)
        #expect(query.query == "SELECT MIN(users.age), MAX(users.age), AVG(users.age) FROM users")
    }
}





@Test
func fullGroupedQuery() {
    let query = SQL
        .SELECT(\.name)
        .FROM(users)
        .WHERE(\.age > 18)
        .GROUP_BY(\.name)
        .HAVING("COUNT(*) > 1")
        .ORDER_BY(\.name, .ASC)
        .LIMIT(10)
        .OFFSET(0)
    #expect(query.query == "SELECT name FROM users WHERE age > $1 GROUP BY name HAVING COUNT(*) > 1 ORDER BY name ASC LIMIT 10 OFFSET 0")
}


// MARK: - HAVING with typed predicates
//
// Needs: Add typed HAVING overloads that accept aggregate conditions instead of raw strings.
//   e.g. .HAVING(COUNT(*) > 5) or .HAVING(SUM(\.age) > 100)
//
//    @Test
//    func HAVINGtyped() {
//        let query = SQL
//            .SELECT(\.name)
//            .FROM(users)
//            .GROUP_BY(\.name)
//            .HAVING(COUNT(*) > 5)
//        #expect(query.query == "SELECT name FROM users GROUP BY name HAVING COUNT(*) > 5")
//    }


// MARK: - CROSS JOIN
//
// Needs: Add CROSS_JOIN method to JoinableQuery:
//   func CROSS_JOIN<Y: Table>(_ table2: Y) -> TypedFromSQLQuery<T, Row>
//
//    @Test
//    func CROSS_JOIN() {
//        let query = TSQL
//            .SELECT((\. name, AS: "username"))
//            .FROM(users)
//            .CROSS_JOIN(orders)
//        #expect(query.query == "SELECT name AS username FROM users CROSS JOIN orders")
//    }


// MARK: - Multiple JOINs (intermediate table references)
//
// Currently JOIN ON clauses must reference the original FROM table on one side.
// Needs: More flexible JOIN overloads that accept JOINPredicates between any two tables:
//   func JOIN<A: Table, B: Table, F>(_ table2: B, ON: JOINPredicate<A, B, F>) -> TypedFromSQLQuery<T, Row>
//
//    @Test
//    func multipleJOINsWithIntermediateTable() {
//        let query = SQL
//            .SELECT(users.name, departments.name)
//            .FROM(users)
//            .JOIN(users_departments, ON: users.uuid == users_departments.user_id)
//            .JOIN(departments, ON: users_departments.department_id == departments.id)
//        #expect(query.query == "SELECT users.name, departments.name FROM users JOIN users_departments ON users.uuid = users_departments.user_id JOIN departments ON users_departments.department_id = departments.id")
//    }


// MARK: - INSERT ... ON CONFLICT (UPSERT)
//
// Needs: Add ON_CONFLICT method to TypedInsertSQLQuery:
//   func ON_CONFLICT(_ columns: ..., DO_UPDATE_SET: ...) -> ...
//   func ON_CONFLICT(DO_NOTHING: ...) -> ...
//
//    @Test
//    func INSERT_ON_CONFLICT_DO_NOTHING() {
//        let query = SQL
//            .INSERT(INTO: users, columns: \.id, \.name,
//                    VALUES: 1, "Alice")
//            .ON_CONFLICT(\.id, DO: .NOTHING)
//        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT (id) DO NOTHING")
//    }
//
//    @Test
//    func INSERT_ON_CONFLICT_DO_UPDATE() {
//        let query = SQL
//            .INSERT(INTO: users, columns: \.id, \.name,
//                    VALUES: 1, "Alice")
//            .ON_CONFLICT(\.id, DO_UPDATE_SET: (\.name, "Alice"))
//        #expect(query.query == "INSERT INTO users (id, name) VALUES ($1, $2) ON CONFLICT (id) DO UPDATE SET name = $3")
//    }


// MARK: - RETURNING on UPDATE / DELETE
//
// Needs: Add RETURNING method to TypedWhereSQLQuery (or a post-WHERE query type):
//   func RETURNING<U>(_ kp: KeyPath<T, TableColumn<T, U>>) -> TypedSQLQuery<T, Void>
//   func RETURNING(_ all: (Int, Int) -> Int) -> TypedSQLQuery<T, Void>  // for *
//


// MARK: - UNION / UNION ALL
//
// Needs: Add UNION / UNION_ALL operators or methods on query types:
//   func UNION(_ other: some SQLQuery) -> ...
//   func UNION_ALL(_ other: some SQLQuery) -> ...
//
//    @Test
//    func UNION() {
//        let q1 = SQL.SELECT(\.name).FROM(users)
//        let q2 = SQL.SELECT(\.name).FROM(employees)
//        let query = q1.UNION(q2)
//        #expect(query.query == "SELECT name FROM users UNION SELECT name FROM employees")
//    }
//
//    @Test
//    func UNION_ALL() {
//        let q1 = SQL.SELECT(\.name).FROM(users)
//        let q2 = SQL.SELECT(\.name).FROM(employees)
//        let query = q1.UNION_ALL(q2)
//        #expect(query.query == "SELECT name FROM users UNION ALL SELECT name FROM employees")
//    }


// MARK: - Subqueries (WHERE ... IN (SELECT ...))
//
// Needs: Add subquery support, e.g.:
//   func WHERE<U>(_ kp: KeyPath<T, TableColumn<T,U>>, IN subquery: some SQLQuery) -> TypedWhereSQLQuery<T, Row>
//
//    @Test
//    func WHEREinSubquery() {
//        let subquery = SQL.SELECT(\.user_id).FROM(orders)
//        let query = SQL
//            .SELECT(*)
//            .FROM(users)
//            .WHERE(\.uuid, IN: subquery)
//        #expect(query.query == "SELECT * FROM users WHERE uuid IN (SELECT user_id FROM orders)")
//    }


// MARK: - WHERE EXISTS / NOT EXISTS
//
// Needs: Add EXISTS / NOT_EXISTS methods:
//   func WHERE(EXISTS subquery: some SQLQuery) -> TypedWhereSQLQuery<T, Row>
//   func WHERE(NOT_EXISTS subquery: some SQLQuery) -> TypedWhereSQLQuery<T, Row>
//
//    @Test
//    func WHEREexists() {
//        let subquery = SQL.SELECT(\.user_id).FROM(orders).WHERE(\.user_id == users.uuid)
//        let query = SQL
//            .SELECT(*)
//            .FROM(users)
//            .WHERE(EXISTS: subquery)
//        #expect(query.query == "SELECT * FROM users WHERE EXISTS (SELECT user_id FROM orders WHERE user_id = users.uuid)")
//    }
//
//    @Test
//    func WHEREnotExists() {
//        let subquery = SQL.SELECT(\.user_id).FROM(orders).WHERE(\.user_id == users.uuid)
//        let query = SQL
//            .SELECT(*)
//            .FROM(users)
//            .WHERE(NOT_EXISTS: subquery)
//        #expect(query.query == "SELECT * FROM users WHERE NOT EXISTS (SELECT user_id FROM orders WHERE user_id = users.uuid)")
//    }


// MARK: - Table aliases (FROM ... AS ...)
//
// Needs: Add table alias support:
//   func FROM(_ table: T, AS alias: String) -> TypedFromSQLQuery<T, Row>
//
//    @Test
//    func FROMwithAlias() {
//        let query = SQL
//            .SELECT(*)
//            .FROM(users, AS: "u")
//        #expect(query.query == "SELECT * FROM users AS u")
//    }


// MARK: - ORDER BY NULLS FIRST / NULLS LAST
//
// Needs: Extend OrderByOrder or add new API:
//   .ORDER_BY(\.name, .ASC, nulls: .FIRST)
//
//    @Test
//    func ORDER_BY_NULLS_FIRST() {
//        let query = SQL
//            .SELECT(*)
//            .FROM(users)
//            .ORDER_BY(\.name, .ASC, nulls: .FIRST)
//        #expect(query.query == "SELECT * FROM users ORDER BY name ASC NULLS FIRST")
//    }
//
//    @Test
//    func ORDER_BY_NULLS_LAST() {
//        let query = SQL
//            .SELECT(*)
//            .FROM(users)
//            .ORDER_BY(\.name, .DESC, nulls: .LAST)
//        #expect(query.query == "SELECT * FROM users ORDER BY name DESC NULLS LAST")
//    }
