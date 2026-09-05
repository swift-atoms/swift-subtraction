import Polarity
import Subtraction
import Testing

@Test
func `UInt8 subtraction agrees with a wider signed oracle`() {
    verify(UInt8.self)
}

@Test
func `Int8 subtraction agrees with a wider signed oracle`() {
    verify(Int8.self)
}

private func verify<Value: FixedWidthInteger>(_ type: Value.Type) {
    for left in 0...255 {
        for right in 0...255 {
            let lhs = Value(truncatingIfNeeded: left)
            let rhs = Value(truncatingIfNeeded: right)
            let oracle = Int16(lhs) - Int16(rhs)
            let overflows = oracle < Int16(Value.min) || oracle > Int16(Value.max)
            let saturated = min(Int16(Value.max), max(Int16(Value.min), oracle))
            let reported = Subtraction.reporting(lhs, rhs)
            #expect(reported.overflow == overflows)
            #expect(reported.value == Value(truncatingIfNeeded: oracle))
            #expect(Subtraction.saturating(lhs, rhs) == Value(saturated))
            do {
                let result = try Subtraction.exact(lhs, rhs)
                #expect(!overflows)
                #expect(Int16(result) == oracle)
            } catch {
                #expect(overflows)
                #expect(error == .overflow)
            }
        }
    }
}

@Test
func `signed magnitude subtraction agrees with a wider signed oracle`() {
    for lhs in Int16(-255)...255 {
        for rhs in Int16(-255)...255 {
            let oracle = lhs - rhs
            let overflows = oracle.magnitude > 255
            let sign: Polarity = oracle < 0 ? .negative : .positive
            let result = Subtraction.Signed.saturating(
                lhsMagnitude: UInt8(lhs.magnitude), lhsPolarity: lhs < 0 ? .negative : .positive,
                rhsMagnitude: UInt8(rhs.magnitude), rhsPolarity: rhs < 0 ? .negative : .positive
            )
            #expect(result.polarity == sign)
            #expect(result.magnitude == UInt8(min(255, oracle.magnitude)))
            do {
                let exact = try Subtraction.Signed.exact(
                    lhsMagnitude: UInt8(lhs.magnitude), lhsPolarity: lhs < 0 ? .negative : .positive,
                    rhsMagnitude: UInt8(rhs.magnitude), rhsPolarity: rhs < 0 ? .negative : .positive
                )
                #expect(!overflows)
                #expect(exact.polarity == sign)
                #expect(UInt16(exact.magnitude) == oracle.magnitude)
            } catch {
                #expect(overflows)
                #expect(error == .overflow)
            }
        }
    }
}

@Test
func `full width subtraction handles signed zero and extreme bounds`() throws {
    let cancellation = try Subtraction.Signed.exact(
        lhsMagnitude: UInt.max, lhsPolarity: .negative,
        rhsMagnitude: UInt.max, rhsPolarity: .negative
    )
    #expect(cancellation.magnitude == 0)
    #expect(cancellation.polarity == .positive)
    for lhs: Polarity in [.negative, .positive] {
        for rhs: Polarity in [.negative, .positive] {
            let zero = try Subtraction.Signed.exact(
                lhsMagnitude: UInt.zero, lhsPolarity: lhs,
                rhsMagnitude: UInt.zero, rhsPolarity: rhs
            )
            #expect(zero.magnitude == 0 && zero.polarity == .positive)
        }
    }
    #expect(Subtraction.saturating(Int.min, 1) == Int.min)
    #expect(Subtraction.saturating(Int.max, -1) == Int.max)
    #expect(try Subtraction.exact(Int.min, Int.min) == 0)
    #expect(throws: Subtraction.Error.overflow) { try Subtraction.exact(UInt.zero, 1) }
}
