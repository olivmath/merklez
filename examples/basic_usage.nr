// Basic usage example for merklez
// This example shows how to use merklez with a custom hash function

use merklez::{Hash, Leaf, Root, merkle_root, merkle_proof, merkle_proof_check, Proof};

// Simple XOR-based hash function (NOT cryptographically secure!)
// This is just for demonstration purposes
// In production, use a proper hash function like Poseidon or Pedersen
fn simple_hash(left: Hash, right: Hash) -> Hash {
    let mut result: Hash = [0; 32];
    for i in 0..32 {
        result[i] = left[i] ^ right[i];
    }
    result
}

fn main() {
    // Step 1: Create some leaves
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    let mut leaf3: Hash = [0; 32];
    let mut leaf4: Hash = [0; 32];

    // Set unique values for each leaf
    leaf1[0] = 1;
    leaf2[0] = 2;
    leaf3[0] = 3;
    leaf4[0] = 4;

    let leaves: [Leaf; 4] = [leaf1, leaf2, leaf3, leaf4];

    // Step 2: Calculate the merkle root
    let root = merkle_root(leaves, 4, simple_hash);

    println(f"Merkle root: {root}");

    // Step 3: Generate a proof for the first leaf
    let proof: Proof<8> = merkle_proof(leaves, 4, 0, simple_hash);

    println(f"Proof length: {proof.len}");

    // Step 4: Verify the proof
    let computed_root = merkle_proof_check(proof, leaf1, simple_hash);

    println(f"Computed root: {computed_root}");

    // Step 5: Assert that the computed root matches the original root
    assert(computed_root == root, "Proof verification failed!");

    println("✓ Proof verified successfully!");
}

// You can also verify a different leaf
fn verify_leaf_at_index_2() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    let mut leaf3: Hash = [0; 32];
    let mut leaf4: Hash = [0; 32];

    leaf1[0] = 1;
    leaf2[0] = 2;
    leaf3[0] = 3;
    leaf4[0] = 4;

    let leaves: [Leaf; 4] = [leaf1, leaf2, leaf3, leaf4];

    // Calculate root
    let root = merkle_root(leaves, 4, simple_hash);

    // Generate proof for leaf at index 2 (leaf3)
    let proof: Proof<8> = merkle_proof(leaves, 4, 2, simple_hash);

    // Verify
    let computed_root = merkle_proof_check(proof, leaf3, simple_hash);

    assert(computed_root == root, "Proof verification failed!");
}
