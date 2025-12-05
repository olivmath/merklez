use merklez::{Proof, merkle_proof_check};
use sha256::sha256;

fn main(pub root: [u8; 32], leaf: [u8; 32], proof: Proof<3]) {
    let computed = merkle_proof_check(proof, leaf, sha256);
    assert(computed == root);
}