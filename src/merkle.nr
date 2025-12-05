// =============================================================================
// MERKLE - Core Merkle Tree operations (root calculation, proof generation, verification)
// =============================================================================

use crate::types::{Hash, Leaf, Root, HashFn};
use crate::side::Side;
use crate::node::Node;
use crate::proof::Proof;

// =============================================================================
// MERKLE ROOT - Calculate the root hash from a list of leaves
// =============================================================================

/// Calculates the Merkle root from an array of leaves
///
/// # Arguments
/// * `leaves` - Array of leaf hashes (bounded by N)
/// * `leaves_len` - Actual number of leaves to use
/// * `hash_fn` - Hash function to combine two hashes
///
/// # Returns
/// The root hash of the Merkle tree
pub fn merkle_root<let N: u32>(
    leaves: [Leaf; N],
    leaves_len: u32,
    hash_fn: HashFn,
) -> Root {
    assert(leaves_len > 0, "Must have at least one leaf");
    assert(leaves_len <= N, "leaves_len exceeds array size");

    // Single leaf case: the leaf itself is the root
    let mut result = leaves[0];
    let single_leaf = leaves_len == 1;

    if !single_leaf {
        let zero_hash: Hash = [0; 32];
        let mut current_level: [Hash; N] = [zero_hash; N];
        let mut current_len = leaves_len;

        // Copy leaves to working array
        for i in 0..N {
            if i < leaves_len {
                current_level[i] = leaves[i];
            }
        }

        // Build tree level by level until we reach the root
        for _level in 0..N {
            if current_len > 1 {
                let mut next_level: [Hash; N] = [zero_hash; N];
                let mut next_len: u32 = 0;

                // Pair up nodes and hash them together
                for i in 0..N {
                    let pair_index = i * 2;
                    if pair_index < current_len {
                        if pair_index + 1 < current_len {
                            // Both nodes exist: hash them together
                            let left = current_level[pair_index];
                            let right = current_level[pair_index + 1];
                            next_level[next_len] = hash_fn(left, right);
                            next_len += 1;
                        } else {
                            // Odd node: promote to next level
                            next_level[next_len] = current_level[pair_index];
                            next_len += 1;
                        }
                    }
                }

                current_level = next_level;
                current_len = next_len;
            }
        }

        result = current_level[0];
    }

    result
}

// =============================================================================
// MERKLE PROOF - Generate a proof for a specific leaf
// =============================================================================

/// Generates a Merkle proof for a leaf at the given index
///
/// # Arguments
/// * `leaves` - Array of leaf hashes
/// * `leaves_len` - Actual number of leaves
/// * `leaf_index` - Index of the leaf to prove
/// * `hash_fn` - Hash function used in the tree
///
/// # Returns
/// A Proof containing the sibling nodes needed for verification
pub fn merkle_proof<let N: u32, let P: u32>(
    leaves: [Leaf; N],
    leaves_len: u32,
    leaf_index: u32,
    hash_fn: HashFn,
) -> Proof<P> {
    assert(leaves_len > 0, "Must have at least one leaf");
    assert(leaf_index < leaves_len, "Leaf index out of bounds");

    let mut proof = Proof::new();
    let single_leaf = leaves_len == 1;

    if !single_leaf {
        let zero_hash: Hash = [0; 32];
        let mut current_level: [Hash; N] = [zero_hash; N];
        let mut current_len = leaves_len;
        let mut current_index = leaf_index;

        // Copy leaves to working array
        for i in 0..N {
            if i < leaves_len {
                current_level[i] = leaves[i];
            }
        }

        // Traverse up the tree, collecting sibling hashes
        for _level in 0..N {
            if current_len > 1 {
                let mut next_level: [Hash; N] = [zero_hash; N];
                let mut next_len: u32 = 0;
                let mut new_index = current_index;

                for i in 0..N {
                    let pair_index = i * 2;
                    if pair_index < current_len {
                        if pair_index + 1 < current_len {
                            let left = current_level[pair_index];
                            let right = current_level[pair_index + 1];

                            // If our target is in this pair, record the sibling
                            if (current_index == pair_index) | (current_index == pair_index + 1) {
                                if current_index == pair_index {
                                    // Target is left, sibling is right
                                    proof.push(Node::new(right, Side::right()));
                                } else {
                                    // Target is right, sibling is left
                                    proof.push(Node::new(left, Side::left()));
                                }
                                new_index = next_len;
                            }

                            next_level[next_len] = hash_fn(left, right);
                            next_len += 1;
                        } else {
                            // Odd node: promote without adding to proof
                            next_level[next_len] = current_level[pair_index];
                            if current_index == pair_index {
                                new_index = next_len;
                            }
                            next_len += 1;
                        }
                    }
                }

                current_level = next_level;
                current_len = next_len;
                current_index = new_index;
            }
        }
    }

    proof
}

// =============================================================================
// MERKLE PROOF CHECK - Verify a proof and compute the root
// =============================================================================

/// Verifies a Merkle proof by computing the root from a leaf and proof path
///
/// # Arguments
/// * `proof` - The Merkle proof (array of sibling nodes)
/// * `leaf` - The leaf hash being verified
/// * `hash_fn` - Hash function used in the tree
///
/// # Returns
/// The computed root hash (compare with expected root to verify)
pub fn merkle_proof_check<let P: u32>(
    proof: Proof<P>,
    leaf: Leaf,
    hash_fn: HashFn,
) -> Root {
    let mut current_hash = leaf;

    // Walk up the proof path, combining hashes
    for i in 0..P {
        if i < proof.len {
            let node = proof.nodes[i];
            if node.side.is_right() {
                // Sibling is on the right: hash(current, sibling)
                current_hash = hash_fn(current_hash, node.data);
            } else {
                // Sibling is on the left: hash(sibling, current)
                current_hash = hash_fn(node.data, current_hash);
            }
        }
    }

    current_hash
}

// =============================================================================
// TESTS
// =============================================================================

/// Simple XOR-based hash function for testing purposes
fn test_hash_fn(left: Hash, right: Hash) -> Hash {
    let mut result: Hash = [0; 32];
    for i in 0..32 {
        result[i] = left[i] ^ right[i];
    }
    result
}

// -----------------------------------------------------------------------------
// merkle_root tests
// -----------------------------------------------------------------------------

#[test]
fn test_merkle_root_single_leaf() {
    let leaves: [Leaf; 1] = [[1; 32]];
    let root = merkle_root(leaves, 1, test_hash_fn);
    // Single leaf should be its own root
    assert(root == [1; 32]);
}

#[test]
fn test_merkle_root_two_leaves() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;

    let leaves: [Leaf; 2] = [leaf1, leaf2];
    let root = merkle_root(leaves, 2, test_hash_fn);

    // Root should be hash(leaf1, leaf2)
    let mut expected: Hash = [0; 32];
    expected[0] = 1 ^ 2; // XOR of first bytes
    assert(root == expected);
}

#[test]
fn test_merkle_root_four_leaves() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    let mut leaf3: Hash = [0; 32];
    let mut leaf4: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;
    leaf3[0] = 3;
    leaf4[0] = 4;

    let leaves: [Leaf; 4] = [leaf1, leaf2, leaf3, leaf4];
    let root = merkle_root(leaves, 4, test_hash_fn);

    // Tree structure:
    //        root
    //       /    \
    //    h12      h34
    //   /  \     /  \
    // l1   l2  l3   l4
    let hash12 = test_hash_fn(leaf1, leaf2);
    let hash34 = test_hash_fn(leaf3, leaf4);
    let expected = test_hash_fn(hash12, hash34);
    assert(root == expected);
}

// -----------------------------------------------------------------------------
// merkle_proof and merkle_proof_check tests
// -----------------------------------------------------------------------------

#[test]
fn test_merkle_proof_two_leaves() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;

    let leaves: [Leaf; 2] = [leaf1, leaf2];
    let root = merkle_root(leaves, 2, test_hash_fn);

    // Generate and verify proof for first leaf
    let proof: Proof<8> = merkle_proof(leaves, 2, 0, test_hash_fn);
    let computed_root = merkle_proof_check(proof, leaf1, test_hash_fn);
    assert(computed_root == root);
}

#[test]
fn test_merkle_proof_four_leaves_all() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    let mut leaf3: Hash = [0; 32];
    let mut leaf4: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;
    leaf3[0] = 3;
    leaf4[0] = 4;

    let leaves: [Leaf; 4] = [leaf1, leaf2, leaf3, leaf4];
    let root = merkle_root(leaves, 4, test_hash_fn);

    // Verify proofs for all four leaves
    let proof0: Proof<8> = merkle_proof(leaves, 4, 0, test_hash_fn);
    let proof1: Proof<8> = merkle_proof(leaves, 4, 1, test_hash_fn);
    let proof2: Proof<8> = merkle_proof(leaves, 4, 2, test_hash_fn);
    let proof3: Proof<8> = merkle_proof(leaves, 4, 3, test_hash_fn);

    assert(merkle_proof_check(proof0, leaf1, test_hash_fn) == root);
    assert(merkle_proof_check(proof1, leaf2, test_hash_fn) == root);
    assert(merkle_proof_check(proof2, leaf3, test_hash_fn) == root);
    assert(merkle_proof_check(proof3, leaf4, test_hash_fn) == root);
}
