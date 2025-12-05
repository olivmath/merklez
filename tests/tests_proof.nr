use crate::types::{Hash, Leaf};
use crate::proof::Proof;
use crate::proof_gen::merkle_proof;
use crate::proof_check::merkle_proof_check;
use crate::root::merkle_root;
use crate::tests_common::test_hash_fn;

#[test]
fn test_merkle_proof_and_verify() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;
    let leaves: [Leaf; 2] = [leaf1, leaf2];
    let root = merkle_root(leaves, 2, test_hash_fn);
    let proof: Proof<8> = merkle_proof(leaves, 2, 0, test_hash_fn);
    let computed_root = merkle_proof_check(proof, leaf1, test_hash_fn);
    assert(computed_root == root);
}

#[test]
fn test_merkle_proof_four_leaves() {
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
    let proof0: Proof<8> = merkle_proof(leaves, 4, 0, test_hash_fn);
    let proof1: Proof<8> = merkle_proof(leaves, 4, 1, test_hash_fn);
    let proof2: Proof<8> = merkle_proof(leaves, 4, 2, test_hash_fn);
    let proof3: Proof<8> = merkle_proof(leaves, 4, 3, test_hash_fn);
    assert(merkle_proof_check(proof0, leaf1, test_hash_fn) == root);
    assert(merkle_proof_check(proof1, leaf2, test_hash_fn) == root);
    assert(merkle_proof_check(proof2, leaf3, test_hash_fn) == root);
    assert(merkle_proof_check(proof3, leaf4, test_hash_fn) == root);
}
