// =============================================================================
// TREE - High-level MerkleTree API wrapper
// =============================================================================

use crate::types::{Hash, Leaf, Root, HashFn};
use crate::proof::Proof;
use crate::merkle::{merkle_root, merkle_proof, merkle_proof_check};

/// High-level Merkle Tree structure that stores leaves and provides
/// convenient methods for proof generation and verification
pub struct MerkleTree<let N: u32> {
    pub root: Root,       // The computed root hash
    pub leaves: [Leaf; N], // The leaf hashes
    pub hash_fn: HashFn,   // Hash function used for this tree
}

impl<let N: u32> MerkleTree<N> {
    /// Creates a new Merkle Tree from an array of leaves
    /// The root is automatically computed during construction
    pub fn new(leaves: [Leaf; N], hash_fn: HashFn) -> Self {
        let root = merkle_root(leaves, N, hash_fn);
        MerkleTree { root, leaves, hash_fn }
    }

    /// Generates a proof for the given leaf
    /// Panics if the leaf is not found in the tree
    pub fn make_proof<let P: u32>(self, leaf: Leaf) -> Proof<P> {
        // Find the leaf index
        let mut index: u32 = N;
        for i in 0..N {
            if self.leaves[i] == leaf {
                index = i;
            }
        }
        assert(index < N, "Leaf not found");

        merkle_proof(self.leaves, N, index, self.hash_fn)
    }

    /// Verifies a proof against this tree's root
    /// Returns true if the proof is valid
    pub fn verify_merkle_proof<let P: u32>(self, leaf: Leaf, proof: Proof<P>) -> bool {
        let computed = merkle_proof_check(proof, leaf, self.hash_fn);
        computed == self.root
    }

    /// Static verification: verifies a proof without needing a tree instance
    /// Useful when you only have the root hash (e.g., in ZK circuits)
    pub fn static_verify_merkle_proof<let P: u32>(
        leaf: Leaf,
        proof: Proof<P>,
        root: Root,
        hash_fn: HashFn,
    ) -> bool {
        let computed = merkle_proof_check(proof, leaf, hash_fn);
        computed == root
    }
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

#[test]
fn test_merkle_tree_new() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;

    let leaves: [Leaf; 2] = [leaf1, leaf2];
    let tree = MerkleTree::new(leaves, test_hash_fn);

    // Verify root is computed correctly
    let mut expected_root: Hash = [0; 32];
    expected_root[0] = 1 ^ 2;
    assert(tree.root == expected_root);
}

#[test]
fn test_merkle_tree_make_proof_and_verify() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;

    let leaves: [Leaf; 2] = [leaf1, leaf2];
    let tree = MerkleTree::new(leaves, test_hash_fn);

    // Generate proof for leaf1
    let proof: Proof<8> = tree.make_proof(leaf1);

    // Verify the proof
    assert(tree.verify_merkle_proof(leaf1, proof));
}

#[test]
fn test_merkle_tree_static_verify() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;

    let leaves: [Leaf; 2] = [leaf1, leaf2];
    let tree = MerkleTree::new(leaves, test_hash_fn);
    let proof: Proof<8> = tree.make_proof(leaf1);

    // Static verification with known root
    let is_valid = MerkleTree::static_verify_merkle_proof(
        leaf1,
        proof,
        tree.root,
        test_hash_fn,
    );
    assert(is_valid);
}
