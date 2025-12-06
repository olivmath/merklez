// =============================================================================
// UTILS - Utility functions for the Merkle Tree library
// =============================================================================

/// Checks if a number is a power of 2
/// Uses bit manipulation: n & (n-1) clears the lowest set bit
/// For powers of 2, there's only one set bit, so the result is 0
/// Note: Returns false for n == 0
pub fn is_power_of_2(n: u32) -> bool {
    if n == 0 {
        false
    } else {
        (n & (n - 1)) == 0
    }
}


// =============================================================================
// TESTS
// =============================================================================

#[test]
fn test_is_power_of_2_valid() {
    assert(is_power_of_2(1)); // 2^0
    assert(is_power_of_2(2)); // 2^1
    assert(is_power_of_2(4)); // 2^2
    assert(is_power_of_2(8)); // 2^3
    assert(is_power_of_2(16)); // 2^4
    assert(is_power_of_2(32)); // 2^5
}

#[test]
fn test_is_power_of_2_invalid() {
    assert(!is_power_of_2(0)); // zero is not a power of 2
    assert(!is_power_of_2(3));
    assert(!is_power_of_2(5));
    assert(!is_power_of_2(6));
    assert(!is_power_of_2(7));
    assert(!is_power_of_2(9));
}
