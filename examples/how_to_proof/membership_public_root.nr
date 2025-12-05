use merklez::{MerkleTree, Node, Side};
use sha256::sha256;

fn main() {
    let leaves: [[u8; 32]; 5] = ["a", "b", "c", "d", "e"].iter().map(|i| sha256(i.as_bytes()));
    let mtree = MerkleTree::new(leaves, sha256);

    let leaf: [u8; 32] = sha256("c".as_bytes());
    let proof = mtree.make_proof(leaf);
    let result = mtree.verify_merkle_proof(leaf, proof);
    assert(result, true);

    let root: [u8; 32] = mtree.root;
    assert(
        root,
        [
            29, 208, 210, 166,
            174, 70, 109, 102,
            92, 178, 110, 26,
            49, 240, 124, 87,
            174, 93, 247, 210,
            188, 85, 156, 213,
            130, 109, 65, 123,
            233, 20, 26, 93
        ]
    );
}
