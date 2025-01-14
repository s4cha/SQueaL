//
//  SQLPredicate.swift
//
//
//  Created by DURAND SAINT OMER Sacha on 04/04/2024.
//

import Foundation


public struct SQLPredicate<T, Y: Encodable> {
    let left: KeyPath<T, Field<Y>>
    let sign: String
    let right: Y
}

public func == <T,Y>(left: KeyPath<T, Field<Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "=", right: right)
}

public func > <T,Y>(left: KeyPath<T, Field<Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: ">", right: right)
}

public func < <T,Y>(left: KeyPath<T, Field<Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "<", right: right)
}

public func >= <T,Y>(left: KeyPath<T, Field<Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: ">=", right: right)
}

public func <= <T,Y>(left: KeyPath<T, Field<Y>>, right: Y) -> SQLPredicate<T, Y> {
    return SQLPredicate(left: left, sign: "<=", right: right)
}

