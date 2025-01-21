//
//  SQLPredicate.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


public struct SQLPredicate<T: Table, Y: Encodable> {
    let left: KeyPath<T, TableColumn<T, Y>>
    let sign: String
    let right: Y
}

public func == <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "=", right: right)
}

public func > <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: ">", right: right)
}

public func < <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "<", right: right)
}

public func >= <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: ">=", right: right)
}

public func <= <T,Y>(left: KeyPath<T, TableColumn<T, Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "<=", right: right)
}

