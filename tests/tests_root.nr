use crate::types::{Hash, Leaf};
use crate::root::merkle_root;
use crate::tests_common::test_hash_fn;

#[test]
fn test_merkle_root_single_leaf() {
    let leaves: [Leaf; 1] = [[1; 32]];
    let root = merkle_root(leaves, 1, test_hash_fn);
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
    let mut expected: Hash = [0; 32];
    expected[0] = 1 ^ 2;
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
    let hash12 = test_hash_fn(leaf1, leaf2);
    let hash34 = test_hash_fn(leaf3, leaf4);
    let expected = test_hash_fn(hash12, hash34);
    assert(root == expected);
}
