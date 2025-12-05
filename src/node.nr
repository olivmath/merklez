// =============================================================================
// NODE - A single node in a Merkle proof
// =============================================================================

use crate::types::Hash;
use crate::side::Side;

/// Represents a single node in a Merkle proof path
/// Each node contains the sibling hash needed for verification
pub struct Node {
    pub data: Hash, // The hash value of the sibling node
    pub side: Side, // Whether this sibling is on the left or right
}

impl Node {
    /// Creates a new proof node with the given hash data and side indicator
    pub fn new(data: Hash, side: Side) -> Self {
        Node { data, side }
    }
}
