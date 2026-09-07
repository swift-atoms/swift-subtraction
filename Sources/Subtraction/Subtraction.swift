public import Addition
public import Polarity


public enum Subtraction {}

extension Subtraction {
    public enum Error: Swift.Error, Hashable, Sendable {
        case overflow
    }

    @inlinable
    public static func reporting<Value: FixedWidthInteger>(
        _ lhs: Value, _ rhs: Value
    ) -> (value: Value, overflow: Bool) {
        let result = lhs.subtractingReportingOverflow(rhs)
        return (result.partialValue, result.overflow)
    }

    @inlinable
    public static func exact<Value: FixedWidthInteger>(
        _ lhs: Value, _ rhs: Value
    ) throws(Subtraction.Error) -> Value {
        let result = reporting(lhs, rhs)
        guard !result.overflow else { throw .overflow }
        return result.value
    }

    @inlinable
    public static func saturating<Value: FixedWidthInteger>(
        _ lhs: Value, _ rhs: Value
    ) -> Value {
        let result = reporting(lhs, rhs)
        guard result.overflow else { return result.value }
        return Value.isSigned && rhs < .zero ? .max : .min
    }


    public enum Signed {}
}

extension Subtraction.Signed {
    @inlinable
    public static func exact<Storage: FixedWidthInteger & UnsignedInteger>(
        lhsMagnitude: Storage, lhsPolarity: Polarity,
        rhsMagnitude: Storage, rhsPolarity: Polarity
    ) throws(Subtraction.Error) -> (polarity: Polarity, magnitude: Storage) {
        do {
            return try Addition.Signed.exact(
                lhsMagnitude: lhsMagnitude, lhsPolarity: lhsPolarity,
                rhsMagnitude: rhsMagnitude, rhsPolarity: rhsPolarity.opposite
            )
        } catch { throw .overflow }
    }

    @inlinable
    public static func saturating<Storage: FixedWidthInteger & UnsignedInteger>(
        lhsMagnitude: Storage, lhsPolarity: Polarity,
        rhsMagnitude: Storage, rhsPolarity: Polarity
    ) -> (polarity: Polarity, magnitude: Storage) {
        Addition.Signed.saturating(
            lhsMagnitude: lhsMagnitude, lhsPolarity: lhsPolarity,
            rhsMagnitude: rhsMagnitude, rhsPolarity: rhsPolarity.opposite
        )
    }
}
