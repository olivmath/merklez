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
    assert(
        proof,
        vec![
            Node {
                data: [
                    241, 145, 142, 133, 98, 35, 110, 177, 122, 220, 133, 2, 51, 47, 76, 156, 130,
                    188, 20, 225, 155, 252, 10, 161, 10, 182, 116, 255, 117, 179, 210, 243
                ],
                side: Side::right()
            },
            Node {
                data: [
                    128, 91, 33, 216, 70, 177, 137, 239, 174, 176, 55, 125, 107, 176, 210, 1, 179,
                    135, 42, 54, 62, 96, 124, 37, 8, 143, 2, 91, 12, 106, 225, 248
                ],
                side: Side::left()
            },
            Node {
                data: [
                    168, 152, 44, 137, 216, 9, 135, 251, 154, 81, 14, 37, 152, 30, 233, 23, 2, 6,
                    190, 33, 175, 60, 142, 14, 179, 18, 239, 29, 51, 130, 231, 97
                ],
                side: Side::right()
            }
        ]
    );
}
