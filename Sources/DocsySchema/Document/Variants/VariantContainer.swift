//
//  VariantContainer.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

// import Foundation
//
// public protocol VariantContainer {}
//
//
// public extension VariantContainer {
//    /// Sets the given value, if present, as the default value of the variant collection at the given key path.
//    ///
//    /// If a variant collection is present, this function updates its default value to the given value. Otherwise, it creates a new variant container with the given
//    /// value as its default value.
//    mutating func setVariantDefaultValue<Value>(
//        _ newValue: Value?,
//        keyPath: WritableKeyPath<Self, VariantCollection<Value>?>
//    ) {
//        if self[keyPath: keyPath] != nil {
//            newValue.map { self[keyPath: keyPath]!.defaultValue = $0 }
//        } else {
//            self[keyPath: keyPath] = newValue.map { VariantCollection<Value>.init(defaultValue: $0) }
//        }
//    }
//
//    /// Returns the default value of the variant collection at the given key path, if present.
//    func getVariantDefaultValue<Value>(
//        keyPath: WritableKeyPath<Self, VariantCollection<Value>?>
//    ) -> Value? {
//        self[keyPath: keyPath]?.defaultValue
//    }
//
//    /// Sets the given value as the default value of the variant collection at the given key path.
//    mutating func setVariantDefaultValue<Value>(
//        _ newValue: Value,
//        keyPath: WritableKeyPath<Self, VariantCollection<Value>>
//    ) {
//        self[keyPath: keyPath].defaultValue = newValue
//    }
//
//    /// Returns the default value of the variant collection at the given key path.
//    func getVariantDefaultValue<Value>(
//        keyPath: WritableKeyPath<Self, VariantCollection<Value>>
//    ) -> Value {
//        self[keyPath: keyPath].defaultValue
//    }
// }
