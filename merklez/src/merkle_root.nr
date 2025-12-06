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
/// # Returns
/// The root hash of the Merkle tree
pub fn merkle_root<let N: u32>(leaves: [Leaf; N], len: u32, hash_fn: HashFn) -> Root {
    let mut level: [Leaf; N] = leaves;
    let mut next_level: [Leaf; N] = leaves;
    let mut curr_len: u32 = len;

    for _p in 0..N {
        if curr_len > 1u32 {
            let mut next_len: u32 = 0u32;
            let mut i: u32 = 0u32;
            for _k in 0..N {
                if i >= curr_len {} else if i + 1u32 < curr_len {
                    next_level[next_len] = hash_fn(level[i], level[i + 1u32]);
                    next_len += 1u32;
                    i += 2u32;
                } else {
                    next_level[next_len] = level[i];
                    next_len += 1u32;
                    i += 1u32;
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

    if curr_len == 0u32 {
        [0u8; 32]
    } else {
        level[0u32]
    }
}

// tests moved to a separate test crate
