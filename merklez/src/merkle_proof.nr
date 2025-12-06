// =============================================================================
// MERKLE PROOF - Generate a Merkle proof for a specific leaf
// =============================================================================

use crate::merkle_proof_mixed::merkle_proof_mixed;
use crate::types::{HashFn, Leaf, Proof};

// =============================================================================
// MERKLE PROOF - Main function
// =============================================================================

/// Generates a Merkle proof for a specific leaf in the tree
///
/// This function uses a bottom-up layer-by-layer approach that works for
/// any tree size (both power-of-2 and non-power-of-2 number of leaves).
///
/// # Arguments
/// * `leaves` - Array of all leaf hashes in the tree
/// * `len` - Number of actual leaves (must be <= N)
/// * `leaf` - The leaf to generate a proof for
/// * `hash_fn` - Hash function to combine two hashes
///
/// # Returns
/// A Proof struct containing the sibling nodes needed to verify the leaf
///
/// # Type Parameters
/// * `N` - Maximum capacity for leaves array
/// * `P` - Maximum capacity for proof nodes (should be log2(N) or more)
///
/// # Example
/// ```
/// let leaves: [Leaf; 4] = [leaf_a, leaf_b, leaf_c, leaf_d];
/// let proof = merkle_proof(leaves, 4, leaf_b, hash_fn);
/// // proof contains the sibling nodes needed to verify leaf_b
/// ```
pub fn merkle_proof<let N: u32, let P: u32>(
    leaves: [Leaf; N],
    len: u32,
    leaf: Leaf,
    hash_fn: HashFn,
) -> Proof<P> {
    merkle_proof_mixed(leaves, len, leaf, hash_fn)
}
