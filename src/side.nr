// =============================================================================
// SIDE - Represents the position of a node in a Merkle proof (left or right)
// =============================================================================

/// Indicates whether a sibling node is on the left (0) or right (1) side
/// Used in Merkle proofs to determine hash concatenation order
pub struct Side {
    pub value: u8, // 0 = left, 1 = right
}

impl Side {
    /// Creates a left side indicator
    pub fn left() -> Self {
        Side { value: 0 }
    }

    /// Creates a right side indicator
    pub fn right() -> Self {
        Side { value: 1 }
    }

    /// Returns true if this is the left side
    pub fn is_left(self) -> bool {
        self.value == 0
    }

    /// Returns true if this is the right side
    pub fn is_right(self) -> bool {
        self.value == 1
    }

    /// Creates a Side from a u8 value (must be 0 or 1)
    pub fn from_u8(value: u8) -> Self {
        assert((value == 0) | (value == 1), "Side value must be 0 or 1");
        Side { value }
    }
}

// =============================================================================
// TESTS
// =============================================================================

#[test]
fn test_side_left() {
    let left = Side::left();
    assert(left.is_left());
    assert(!left.is_right());
    assert(left.value == 0);
}

#[test]
fn test_side_right() {
    let right = Side::right();
    assert(right.is_right());
    assert(!right.is_left());
    assert(right.value == 1);
}

#[test]
fn test_side_from_u8() {
    let left = Side::from_u8(0);
    let right = Side::from_u8(1);
    assert(left.is_left());
    assert(right.is_right());
}
