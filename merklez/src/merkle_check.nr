// =============================================================================
// MERKLE PROOF CHECK - Verify a Merkle proof and compute the root
// =============================================================================

use crate::side::Side;
use crate::types::{HashFn, Leaf, Proof, Root};

// =============================================================================
// MERKLE PROOF CHECK - Main function
// =============================================================================

/// Verifies a Merkle proof and computes the root hash
///
/// This function takes a proof (list of sibling nodes with their positions),
/// a leaf value, and a hash function, then reconstructs the path to the root
/// by combining the leaf with each proof node according to their side indicator.
///
/// # Arguments
/// * `proof` - A Proof struct containing sibling nodes and their positions
/// * `leaf` - The leaf value to verify
/// * `hash_fn` - Hash function to combine two hashes
///
/// # Returns
/// The computed root hash after applying all proof nodes
///
/// # Type Parameters
/// * `P` - Proof capacity (maximum number of nodes in the proof path)
///
/// # How it works
/// Starting from the leaf, for each proof node:
/// - If the node is on the LEFT, compute hash(node.data, current_hash)
/// - If the node is on the RIGHT, compute hash(current_hash, node.data)
///
/// The final hash is the Merkle root.
///
/// # Example
/// ```
/// let proof: Proof<3> = /* proof for a leaf */;
/// let leaf: Leaf = /* leaf to verify */;
/// let root = merkle_proof_check(proof, leaf, hash_fn);
/// // root is the computed Merkle root
/// ```
pub fn merkle_proof_check<let P: u32>(proof: Proof<P>, leaf: Leaf, hash_fn: HashFn) -> Root {
    let mut current_hash = leaf;

    for i in 0..P {
        if i < proof.len {
            let node = proof.nodes[i];
            current_hash = if node.side.is_right {
                hash_fn(current_hash, node.data)
            } else {
                hash_fn(node.data, current_hash)
            };
        }
    }

    current_hash
}
