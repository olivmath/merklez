use merklez::{Proof, merkle_proof_check};
use sha256::sha256;

fn main(pub root: [u8; 32], leaf: [u8; 32], proof: Proof<3>) {
    let computed = merkle_proof_check(proof, leaf, sha256);
    assert(computed == root);
}

// you need add sha256 in your Nargo.toml:
//
// ```toml
// [dependencies]
// sha256 = { tag = "v0.2.1", git = "https://github.com/noir-lang/sha256" }
// ```