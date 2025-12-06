// =============================================================================
// NODE - A single node in a Merkle proof
// =============================================================================

use crate::side::Side;
use crate::types::Hash;

/// Represents a single node in a Merkle proof path
/// Each node contains the sibling hash needed for verification
pub struct Node {
    // The hash value of the sibling node
    pub data: Hash,
    // Whether this sibling is on the left or right
    pub side: Side,
}
