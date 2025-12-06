// =============================================================================
// MERKLE - Core Merkle Tree operations (root calculation, proof generation, verification)
// =============================================================================

use crate::types::{HashFn, Leaf, Root};

// =============================================================================
// MERKLE ROOT - Calculate the root hash from a list of leaves
// =============================================================================

/// Calculates the Merkle root from an array of leaves
///
/// # Arguments
/// * `leaves` - Array of leaf hashes
/// * `hash_fn` - Hash function to combine two hashes
///
/// # Type Parameters
/// * `N` - Number of leaves in the tree
///
/// # Returns
/// The root hash of the Merkle tree
pub fn merkle_root<let N: u32>(leaves: [Leaf; N], hash_fn: HashFn) -> Root {
    let mut level: [Leaf; N] = leaves;
    let mut next_level: [Leaf; N] = leaves;
    let mut curr_len: u32 = N;

    for _p in 0..N {
        if curr_len > 1 {
            let mut next_len: u32 = 0;
            let mut i: u32 = 0;
            for _k in 0..N {
                if i >= curr_len {} else if i + 1 < curr_len {
                    next_level[next_len] = hash_fn(level[i], level[i + 1]);
                    next_len += 1;
                    i += 2;
                } else {
                    next_level[next_len] = level[i];
                    next_len += 1;
                    i += 1;
                }
            }
            for j in 0..N {
                if j < next_len {
                    level[j] = next_level[j];
                }
            }
            curr_len = next_len;
        }
    }

    if N == 0 {
        [0u8; 32]
    } else {
        level[0]
    }
}

// tests moved to a separate test crate
