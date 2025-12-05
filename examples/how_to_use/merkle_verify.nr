use merklez::{MerkleTree, Node, Side};
use sha256::sha256;

fn main() {
    // Step 1: Create some leaves
    let leaves: [[u8; 32]; 5] = ["a", "b", "c", "d", "e"].iter().map(|i| sha256(i.as_bytes()));

    // Step 2: Calculate the merkle tree
    let mtree = MerkleTree::new(leaves, sha256);

    // Step 3: Calculate merkle proof for 'c' element
    let leaf: [u8; 32] = sha256("c".as_bytes());
    let proof = mtree.make_proof(leaf);
    
    // Step 4: Calculate if proof is valid
    let result = mtree.verify_merkle_proof(leaf, proof);
    assert(result, true);

    // Step 4': Calculate if proof is valid [Static Mode]
    let result2 = mtree.static_verify_merkle_proof(leaf, proof, mtree.root, sha256);
    assert(result2, true);
}
