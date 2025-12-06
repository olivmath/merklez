// =============================================================================
// MERKLE PROOF MIXED - Proof generation for any tree (works with all sizes)
// =============================================================================

use crate::node::Node;
use crate::side::Side;
use crate::types::{HashFn, Leaf, Proof};

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Find the index of a leaf in an array of leaves
/// Returns the index if found, or N (out of bounds) if not found
fn find_leaf_index<let N: u32>(leaves: [Leaf; N], target: Leaf) -> u32 {
    let mut index: u32 = N; // Default to out of bounds
    let mut found = false;
    for i in 0..N {
        if !found {
            let mut is_equal = true;
            for j in 0..32 {
                if leaves[i][j] != target[j] {
                    is_equal = false;
                }
            }
            if is_equal {
                index = i;
                found = true;
            }
        }
    }
    index
}

/// Compute the next layer up in the Merkle tree
/// Pairs leaves and hashes them together
/// Odd leaves are promoted to the next layer unchanged
fn up_layer<let N: u32>(leaves: [Leaf; N], len: u32, hash_fn: HashFn) -> ([Leaf; N], u32) {
    let mut new_layer: [Leaf; N] = [[0u8; 32]; N];
    let mut new_len: u32 = 0;
    let mut i: u32 = 0;

    for _k in 0..N {
        if i < len {
            if i + 1 < len {
                new_layer[new_len] = hash_fn(leaves[i], leaves[i + 1]);
                new_len += 1;
                i += 2;
            } else {
                new_layer[new_len] = leaves[i];
                new_len += 1;
                i += 1;
            }
        }
    }

    (new_layer, new_len)
}

// =============================================================================
// MERKLE PROOF MIXED - Main function (bottom-up approach)
// =============================================================================

/// Generates a Merkle proof using the bottom-up layer-by-layer approach
/// Works for any tree size (power-of-2 and non-power-of-2)
///
/// # Arguments
/// * `leaves` - Array of all leaf hashes in the tree
/// * `leaf` - The leaf to generate a proof for
/// * `hash_fn` - Hash function to combine two hashes
///
/// # Returns
/// A Proof struct containing the sibling nodes needed to verify the leaf
pub fn merkle_proof_mixed<let N: u32, let P: u32>(
    leaves: [Leaf; N],
    leaf: Leaf,
    hash_fn: HashFn,
) -> Proof<P> {
    let mut proof_nodes: [Node; P] = [Node { data: [0u8; 32], side: Side::left() }; P];
    let mut proof_len: u32 = 0;

    // Handle edge cases: N == 0 or N == 1 means no proof needed
    // We use a flag to skip the main logic in these cases
    let should_process = N > 1;

    if should_process {
        // Find the target leaf index
        let initial_index = find_leaf_index(leaves, leaf);
        assert(initial_index < N, "Leaf does not exist in the tree");

        // Track current position in the tree
        let mut leaf_index: u32 = initial_index;
        let mut current_leaves: [Leaf; N] = leaves;
        let mut current_len: u32 = N;

        // Build proof by traversing up the tree layer by layer
        for _level in 0..P {
            if current_len > 1 {
                // Determine sibling position
                if leaf_index % 2 == 0 {
                    // Current node is at even index, sibling is to the right
                    if leaf_index + 1 < current_len {
                        proof_nodes[proof_len] = Node {
                            data: current_leaves[leaf_index + 1],
                            side: Side::right(),
                        };
                        proof_len += 1;
                    }
                    // If no sibling (odd-length layer), no node is added
                } else {
                    // Current node is at odd index, sibling is to the left
                    proof_nodes[proof_len] = Node {
                        data: current_leaves[leaf_index - 1],
                        side: Side::left(),
                    };
                    proof_len += 1;
                }

                // Move up to the next layer
                let (next_layer, next_len) = up_layer(current_leaves, current_len, hash_fn);
                current_leaves = next_layer;
                current_len = next_len;
                leaf_index = leaf_index / 2;
            }
        }
    }

    Proof { nodes: proof_nodes, len: proof_len }
}
