// =============================================================================
// SIDE - Represents the position of a node in a Merkle proof (left or right)
// =============================================================================

/// Indicates whether a sibling node is on the left (0) or right (1) side
/// Used in Merkle proofs to determine hash concatenation order

#[derive(PartialEq, Debug, Clone)]
pub enum Side {
    LEFT = 0,
    RIGHT = 1
}

impl From<u8> for Side {
    fn from(side: u8) -> Self {
         match side {
            0 => Side::LEFT,
            1 => Side::RIGHT,
            _ => panic!("Invalid value for Side enum, must be either `0` or `1`"),
        }
    }
}

// =============================================================================
// TESTS
// =============================================================================

#[test]
fn test_side_left() {
    let left = Side::LEFT;
    assert(left == Side::LEFT);
    assert(left != Side::RIGHT);
}

#[test]
fn test_side_right() {
    let right = Side::RIGHT;
    assert(right == Side::RIGHT);
    assert(right != Side::LEFT);
}

#[test]
fn test_side_from_u8() {
    let left = Side::from(0u8);
    let right = Side::from(1u8);
    assert(left == Side::LEFT);
    assert(right == Side::RIGHT);
}
