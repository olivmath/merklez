use crate::types::{Hash, Leaf};
use crate::proof::Proof;
use crate::tests_common::test_hash_fn;
use crate::tree::MerkleTree;

#[test]
fn test_merkle_tree_api() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;
    let leaves: [Leaf; 2] = [leaf1, leaf2];
    let mtree = MerkleTree::new(leaves, test_hash_fn);
    let proof: Proof<8> = mtree.make_proof(leaf1);
    assert(mtree.verify_merkle_proof(leaf1, proof));
}
