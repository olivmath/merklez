// =============================================================================
// SIDE - Represents the position of a node in a Merkle proof (left or right)
// =============================================================================

/// Indicates whether a sibling node is on the left (0) or right (1) side
/// Used in Merkle proofs to determine hash concatenation order

pub struct Side {
    pub is_right: bool,
}

impl Side {
    pub fn left() -> Self {
        Self { is_right: false }
    }
    pub fn right() -> Self {
        Self { is_right: true }
    }
}

impl From<u8> for Side {
    fn from(side: u8) -> Self {
        assert((side == 0u8) | (side == 1u8));
        if side == 0u8 {
            Self::left()
        } else {
            Self::right()
        }
    }
}

impl Eq for Side {
    fn eq(self, other: Self) -> bool {
        self.is_right == other.is_right
    }
}

// =============================================================================
// TESTS
// =============================================================================

#[test]
fn test_side_left() {
    let left = Side::left();
    assert(left == Side::left());
    assert(left != Side::right());
}

#[test]
fn test_side_right() {
    let right = Side::right();
    assert(right == Side::right());
    assert(right != Side::left());
}

#[test]
fn test_side_from_u8() {
    let left = Side::from(0u8);
    let right = Side::from(1u8);
    assert(left == Side::left());
    assert(right == Side::right());
}
