use merklez::{merkle_proof, merkle_proof_check, merkle_root, Proof};
use sha256::sha256;

fn main() {
    // Step 1: Create some leaves
    let mut leaf_a: [u8; 32] = [0; 32];
    leaf_a[0] = 1;
    let mut leaf_b: [u8; 32] = [0; 32];
    leaf_b[0] = 2;
    let mut leaf_c: [u8; 32] = [0; 32];
    leaf_c[0] = 3;
    let mut leaf_d: [u8; 32] = [0; 32];
    leaf_d[0] = 4;

    let leaves: [[u8; 32]; 4] = [leaf_a, leaf_b, leaf_c, leaf_d];

    // Step 2: Calculate merkle root
    let root = merkle_root(leaves, sha256);

    // Step 3: Generate proof for leaf_c
    let proof: Proof<2> = merkle_proof(leaves, leaf_c, sha256);

    // Step 4: Verify proof using merkle_proof_check
    // This function reconstructs the root from the leaf and proof
    let computed_root = merkle_proof_check(proof, leaf_c, sha256);

    // Step 5: Compare computed root with expected root
    assert(computed_root == root);
}

// you need add sha256 in your Nargo.toml:
//
// ```toml
// [dependencies]
// sha256 = { tag = "v0.2.1", git = "https://github.com/noir-lang/sha256" }
// ```
