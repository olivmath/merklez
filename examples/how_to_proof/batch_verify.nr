use merklez::{MerkleTree, Node, Side};
use sha256::sha256;

fn main() {
    let leaves: [[u8; 32]; 5] = ["a", "b", "c", "d", "e"].iter().map(|i| sha256(i.as_bytes()));
    let mtree = MerkleTree::new(leaves, sha256);

    let leaf_a: [u8; 32] = sha256("a".as_bytes());
    let leaf_b: [u8; 32] = sha256("b".as_bytes());
    let leaf_c: [u8; 32] = sha256("c".as_bytes());
    let leaf_d: [u8; 32] = sha256("d".as_bytes());

    let proof_a = mtree.make_proof(leaf_a);
    let proof_b = mtree.make_proof(leaf_b);
    let proof_c = mtree.make_proof(leaf_c);
    let proof_d = mtree.make_proof(leaf_d);

    let ra = mtree.verify_merkle_proof(leaf_a, proof_a);
    let rb = mtree.verify_merkle_proof(leaf_b, proof_b);
    let rc = mtree.verify_merkle_proof(leaf_c, proof_c);
    let rd = mtree.verify_merkle_proof(leaf_d, proof_d);

    assert(ra, true);
    assert(rb, true);
    assert(rc, true);
    assert(rd, true);
}
