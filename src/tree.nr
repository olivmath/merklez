use crate::types::{Leaf, Root, HashFn};
use crate::proof::Proof;
use crate::proof_check::merkle_proof_check;
use crate::proof_gen::merkle_proof;
use crate::root::merkle_root;

pub struct MerkleTree<let N: u32> {
    pub root: Root,
    pub leaves: [Leaf; N],
    pub hash_fn: HashFn,
}

impl<let N: u32> MerkleTree<N> {
    pub fn new(leaves: [Leaf; N], hash_fn: HashFn) -> Self {
        let root = merkle_root(leaves, N, hash_fn);
        MerkleTree { root, leaves, hash_fn }
    }

    pub fn make_proof<let P: u32>(self, leaf: Leaf) -> Proof<P> {
        let mut index: u32 = N;
        for i in 0..N {
            if self.leaves[i] == leaf { index = i; }
        }
        assert(index < N, "Leaf not found");
        merkle_proof(self.leaves, N, index, self.hash_fn)
    }

    pub fn verify_merkle_proof<let P: u32>(self, leaf: Leaf, proof: Proof<P>) -> bool {
        let computed = merkle_proof_check(proof, leaf, self.hash_fn);
        computed == self.root
    }

    pub fn static_verify_merkle_proof<let P: u32>(leaf: Leaf, proof: Proof<P>, root: Root, hash_fn: HashFn) -> bool {
        let computed = merkle_proof_check(proof, leaf, hash_fn);
        computed == root
    }
}
