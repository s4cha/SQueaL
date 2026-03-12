//
//  SELECTTests.swift
//
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import Testing
import Squeal


struct SELECTTests {
    
    @Test
    func SELECTall() {
        let query = SQL
            .SELECT(*)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT * FROM users")
        #expect("\(query)" == "SELECT * FROM users")
    }
    
    func SELECTCount() {
        let query = SQL
            .SELECT(COUNT(*)) // TODO be int
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT COUNT(*) FROM users")
        #expect("\(query)" == "SELECT COUNT(*) FROM users")
    }
    
    @Test
    func SELECTHeterogeneousList1() {
        let query = SQL
            .SELECT(users.name)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT users.name FROM users")
        #expect("\(query)" == "SELECT users.name FROM users")
    }
    
    @Test
    func SELECTHeterogeneousList2() {
        let query = SQL
            .SELECT(users.id, users.name)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT users.id, users.name FROM users")
        #expect("\(query)" == "SELECT users.id, users.name FROM users")
    }
    
    @Test
    func SELECTHeterogeneousList3() {
        let query = SQL
            .SELECT(users.id, COUNT(users.name))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT users.id, COUNT(users.name) FROM users")
        #expect("\(query)" == "SELECT users.id, COUNT(users.name) FROM users")
    }
    
    @Test
    func SELECTHeterogeneousList4() {
        let query = SQL
            .SELECT(COUNT(*), COUNT(users.name))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT COUNT(*), COUNT(users.name) FROM users")
        #expect("\(query)" == "SELECT COUNT(*), COUNT(users.name) FROM users")
    }
    
    @Test
    func SELECTCountNameShortKeyPath() {
        let query = SQL
            .SELECT(COUNT(\UsersTable.name))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT COUNT(name) FROM users")
        #expect("\(query)" == "SELECT COUNT(name) FROM users")
    }
    
    @Test
    func SELECT1Column() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id FROM users")
        #expect("\(query)" == "SELECT id FROM users")
    }
    
    @Test
    func SELECTWithSingleField() {
        let query = SQL
            .SELECT(\UsersTable.id)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id")
        #expect("\(query)" == "SELECT id")
    }
    
    @Test
    func SELECTWithSingleFieldAndFROM() {
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id FROM users")
        #expect("\(query)" == "SELECT id FROM users")
    }
    
    @Test
    func SELECTCountWithSingleField() {
        let query = SQL
            .SELECT(COUNT(\UsersTable.id))
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT COUNT(id)")
        #expect("\(query)" == "SELECT COUNT(id)")
    }
    
    @Test
    func SELECTCountWithSingleFieldAndFROM() {
        let query = TSQL<UsersTable>
            .SELECT(COUNT(\UsersTable.id))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT COUNT(id) FROM users")
        #expect("\(query)" == "SELECT COUNT(id) FROM users")
    }

    @Test
    func SELECT2Columns() {
        let query = SQL
            .SELECT(\.id, \.name)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id, name FROM users")
        #expect("\(query)" == "SELECT id, name FROM users")
    }
    
    @Test
    func SELECTVariadicColumns() {
        let query = SQL
            .SELECT(\.uuid, \.id, \.name)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT uuid, id, name FROM users")
        #expect("\(query)" == "SELECT uuid, id, name FROM users")
    }
    
    @Test
    func SELECTVariadicColumnsTyped() {
        let query = TSQL
            .SELECT(\.uuid, \.id, \.name)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT uuid, id, name FROM users")
        #expect("\(query)" == "SELECT uuid, id, name FROM users")
    }

    @Test
    func SELECTypesShortKeypath() {
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
        #expect(query.parameters.isEmpty)
        #expect(query.query == "SELECT name FROM users")
        #expect("\(query)" == "SELECT name FROM users")
    }
    
    // Aliases
    
    // Cannot convert value of type 'any WritableKeyPath<UsersTable, TableColumn<UsersTable, Int>> & Sendable' to expected argument type '(KeyPath<String, TableColumn<String, _>>, AS: String)'

    @Test
    func testSelectAS() {
        let query = SQL
            .SELECT((\UsersTable.id, AS: "user_id"))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id AS user_id FROM users")
        #expect("\(query)" == "SELECT id AS user_id FROM users")
    }
    
    @Test
    func testSelectASTyped() {
        let query = TSQL
            .SELECT((\.id, AS: "user_id"))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT id AS user_id FROM users")
        #expect("\(query)" == "SELECT id AS user_id FROM users")
    }

    @Test
    func testSelectMultipleAS() {
        let query = TSQL
            .SELECT(
                (\.uuid, AS: "unique_id"),
                (\.id, AS: "user_id"),
                (\.name, AS: "username"))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT uuid AS unique_id, id AS user_id, name AS username FROM users")
        #expect("\(query)" == "SELECT uuid AS unique_id, id AS user_id, name AS username FROM users")
    }
    
    // DISTINCT
    
    @Test
    func SELECT_DISTINCT() {
        let query = SQL
            .SELECT_DISTINCT(\.name)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT DISTINCT name FROM users")
        #expect("\(query)" == "SELECT DISTINCT name FROM users")
    }
    
    @Test
    func multipleSELECT_DISTINCT() {
        let query = SQL
            .SELECT_DISTINCT(\.id, \.name)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT DISTINCT id, name FROM users")
        #expect("\(query)" == "SELECT DISTINCT id, name FROM users")
    }
    
    @Test
    func multipleSELECT_DISTINCTTyped() {
        let query = TSQL
            .SELECT_DISTINCT(\.id, \.name)
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT DISTINCT id, name FROM users")
        #expect("\(query)" == "SELECT DISTINCT id, name FROM users")
    }
   
    @Test
    func SELECT_DISTINCTwithAliase() {
        let query = SQL
            .SELECT_DISTINCT((\UsersTable.name, AS: "username"))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT DISTINCT name AS username FROM users")
        #expect("\(query)" == "SELECT DISTINCT name AS username FROM users")
    }
    
    @Test
    func SELECT_DISTINCTwithAliaseTyped() {
        let query = TSQL
            .SELECT_DISTINCT((\.name, AS: "username"))
            .FROM(users)
        #expect(query.parameters.count == 0)
        #expect(query.query == "SELECT DISTINCT name AS username FROM users")
        #expect("\(query)" == "SELECT DISTINCT name AS username FROM users")
    }
}
    
    
