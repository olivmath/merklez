use crate::types::{Leaf, Root, HashFn};
use crate::proof::Proof;

pub fn merkle_proof_check<let P: u32>(proof: Proof<P>, leaf: Leaf, hash_fn: HashFn) -> Root {
    let mut current_hash = leaf;

    for i in 0..P {
        if i < proof.len {
            let node = proof.nodes[i];
            if node.side.is_right() {
                current_hash = hash_fn(current_hash, node.data);
            } else {
                current_hash = hash_fn(node.data, current_hash);
            }
        }
    }

    current_hash
}
