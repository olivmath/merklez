// =============================================================================
// PROOF - Merkle proof structure (bounded array of nodes)
// =============================================================================

use crate::node::Node;
use crate::side::Side;
use crate::types::Hash;

/// A Merkle proof consisting of a path from a leaf to the root
/// N is the maximum proof depth (should be >= log2(num_leaves))
pub struct Proof<let N: u32> {
    pub nodes: [Node; N], // Array of sibling nodes in the proof path
    pub len: u32,         // Actual number of nodes used
}

impl<let N: u32> Proof<N> {
    /// Creates an empty proof with capacity for N nodes
    pub fn new() -> Self {
        let empty_hash: Hash = [0; 32];
        let empty_node = Node::new(empty_hash, Side::left());
        Proof { nodes: [empty_node; N], len: 0 }
    }

    /// Adds a node to the proof path
    /// Panics if the proof is already full
    pub fn push(&mut self, node: Node) {
        assert(self.len < N, "Proof is full");
        self.nodes[self.len] = node;
        self.len += 1;
    }

    /// Retrieves a node at the given index
    /// Panics if index is out of bounds
    pub fn get(self, index: u32) -> Node {
        assert(index < self.len, "Index out of bounds");
        self.nodes[index]
    }
}
