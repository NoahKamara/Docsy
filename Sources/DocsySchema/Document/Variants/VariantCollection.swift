//
//  VariantCollection.swift
//  Docsy
//
//  Copyright © 2024 Noah Kamara.
//

//
//
///// A collection of variants for a document value.
/////
///// Variant collections encapsulate different values for the same piece of content. Each variant collection has a default value and optionally, trait-specific
///// (e.g., programming language–specific) values that client can choose to use based on their context.
/////
///// For example, a collection can a hold programming language-agnostic documentation value as its ``defaultValue``, and hold Objective-C specific values
///// in its ``variants`` array. Clients that want to process the Objective-C version of a documentation page then use the override rather than the
///// default value, and fall back to the default value if no Objective-C-specific override is specified.
// public struct VariantCollection<Value: Decodable>: Decodable {
//    /// The default value of the variant.
//    ///
//    /// Clients should decide whether the `defaultValue` or a value in ``variants`` is appropriate in their context.
//    public var defaultValue: Value
//
//    /// Trait-specific overrides for the default value.
//    ///
//    /// Clients should decide whether the `defaultValue` or a value in ``variants`` is appropriate in their context.
//    public var variants: [Variant]
//
//    /// Creates a variant collection given a default value and an array of trait-specific overrides.
//    ///
//    /// - Parameters:
//    ///   - defaultValue: The default value of the variant.
//    ///   - variants: The trait-specific overrides for the value.
//    public init(defaultValue: Value, variants: [Variant] = []) {
//        self.defaultValue = defaultValue
//        self.variants = variants
//    }
//
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        self.defaultValue = try container.decode(Value.self)
//
//        // When decoding a document, the variants overrides stored in the `RenderNode.variantOverrides` property.
//        self.variants = []
//    }
//
//    /// Returns a variant collection containing the results of calling the given transformation with each value of this variant collection.
//    public func mapValues<TransformedValue>(
//        _ transform: (Value) -> TransformedValue
//    ) -> VariantCollection<TransformedValue> {
//        VariantCollection<TransformedValue>(
//            defaultValue: transform(defaultValue),
//            variants: variants.map { variant in
//                variant.mapPatch(transform)
//            }
//        )
//    }
// }
//
// extension VariantCollection: Equatable where Value: Equatable {
//    public static func == (lhs: VariantCollection<Value>, rhs: VariantCollection<Value>) -> Bool {
//        guard lhs.defaultValue == rhs.defaultValue else { return false }
//        guard lhs.variants == rhs.variants else { return false }
//
//        return true
//    }
// }
