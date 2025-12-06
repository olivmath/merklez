use dep::keccak256::keccak256;
use dep::merklez::merkle_proof::merkle_proof;
use dep::merklez::merkle_root::merkle_root;
use dep::merklez::node::Node;
use dep::merklez::side::Side;
use dep::merklez::types::{Hash, Leaf, Proof, Root};

fn keccak_hash(left: Hash, right: Hash) -> Hash {
    let mut input: [u8; 64] = [0u8; 64];
    for i in 0..32 {
        input[i] = left[i];
        input[i + 32] = right[i];
    }
    keccak256(input, 64u32)
}

/// Helper function to verify a proof by computing the root
fn verify_proof<let P: u32>(leaf: Leaf, proof: Proof<P>, hash_fn: fn(Hash, Hash) -> Hash) -> Root {
    let mut current: Hash = leaf;
    for i in 0..P {
        if i < proof.len {
            let node = proof.nodes[i];
            if node.side.is_right {
                // Sibling is on the right
                current = hash_fn(current, node.data);
            } else {
                // Sibling is on the left
                current = hash_fn(node.data, current);
            }
        }
    }
    current
}

// =============================================================================
// TEST DATA - Standard leaves keccak256 of "a", "b", "c", "d", "e", "f"
// =============================================================================

fn get_leaf_a() -> Leaf {
    [
        58, 194, 37, 22, 141, 245, 66, 18, 162, 92, 28, 1, 253, 53, 190, 191, 234, 64, 143, 218,
        194, 227, 29, 221, 111, 128, 164, 187, 249, 165, 241, 203,
    ]
}

fn get_leaf_b() -> Leaf {
    [
        181, 85, 61, 227, 21, 224, 237, 245, 4, 217, 21, 10, 248, 45, 175, 165, 196, 102, 127,
        166, 24, 237, 10, 111, 25, 198, 155, 65, 22, 108, 85, 16,
    ]
}

fn get_leaf_c() -> Leaf {
    [
        11, 66, 182, 57, 60, 31, 83, 6, 15, 227, 221, 191, 205, 122, 173, 204, 168, 148, 70, 90,
        90, 67, 143, 105, 200, 125, 121, 11, 34, 153, 185, 178,
    ]
}

fn get_leaf_d() -> Leaf {
    [
        241, 145, 142, 133, 98, 35, 110, 177, 122, 220, 133, 2, 51, 47, 76, 156, 130, 188, 20,
        225, 155, 252, 10, 161, 10, 182, 116, 255, 117, 179, 210, 243,
    ]
}

fn get_leaf_e() -> Leaf {
    [
        168, 152, 44, 137, 216, 9, 135, 251, 154, 81, 14, 37, 152, 30, 233, 23, 2, 6, 190, 33,
        175, 60, 142, 14, 179, 18, 239, 29, 51, 130, 231, 97,
    ]
}

fn get_leaf_f() -> Leaf {
    [
        209, 232, 174, 183, 149, 0, 73, 110, 243, 220, 46, 87, 186, 116, 106, 131, 21, 208, 72,
        183, 166, 100, 162, 191, 148, 141, 180, 250, 145, 150, 4, 131,
    ]
}

// =============================================================================
// TESTS - 6 leaves (even, non-power of 2) - Proof for leaf E (index 4)
// =============================================================================

#[test]
fn test_merkle_proof_leaves_even_make_proof() {
    // 6 leaves: [a, b, c, d, e, f]
    let leaves: [Leaf; 6] = [
        get_leaf_a(),
        get_leaf_b(),
        get_leaf_c(),
        get_leaf_d(),
        get_leaf_e(),
        get_leaf_f(),
    ];

    // Target: leaf E (index 4)
    let target = get_leaf_e();

    // Expected proof from Rust implementation
    let expected_proof: [Node; 2] = [
        Node {
            data: [
                209, 232, 174, 183, 149, 0, 73, 110, 243, 220, 46, 87, 186, 116, 106, 131, 21,
                208, 72, 183, 166, 100, 162, 191, 148, 141, 180, 250, 145, 150, 4, 131,
            ],
            side: Side::right(),
        },
        Node {
            data: [
                104, 32, 63, 144, 233, 208, 125, 197, 133, 146, 89, 215, 83, 110, 135, 166,
                186, 157, 52, 95, 37, 82, 181, 185, 222, 41, 153, 221, 206, 156, 225, 191,
            ],
            side: Side::left(),
        },
    ];

    let proof: Proof<4> = merkle_proof(leaves, 6, target, keccak_hash);

    assert(proof.len == 2);
    assert(proof.nodes[0] == expected_proof[0]);
    assert(proof.nodes[1] == expected_proof[1]);

    // Also verify the proof produces the correct root
    let expected_root = merkle_root(leaves, 6, keccak_hash);
    let computed_root = verify_proof(target, proof, keccak_hash);
    assert(computed_root == expected_root);
}

// =============================================================================
// TESTS - 5 leaves (odd, non-power of 2) - Proof for leaf D (index 3)
// =============================================================================

#[test]
fn test_merkle_proof_leaves_odd_make_proof() {
    // 5 leaves: [a, b, c, d, e]
    let leaves: [Leaf; 5] = [
        get_leaf_a(),
        get_leaf_b(),
        get_leaf_c(),
        get_leaf_d(),
        get_leaf_e(),
    ];

    // Target: leaf D (index 3)
    let target = get_leaf_d();

    // Expected proof from Rust implementation
    let expected_proof: [Node; 3] = [
        Node {
            data: [
                11, 66, 182, 57, 60, 31, 83, 6, 15, 227, 221, 191, 205, 122, 173, 204, 168,
                148, 70, 90, 90, 67, 143, 105, 200, 125, 121, 11, 34, 153, 185, 178,
            ],
            side: Side::left(),
        },
        Node {
            data: [
                128, 91, 33, 216, 70, 177, 137, 239, 174, 176, 55, 125, 107, 176, 210, 1, 179,
                135, 42, 54, 62, 96, 124, 37, 8, 143, 2, 91, 12, 106, 225, 248,
            ],
            side: Side::left(),
        },
        Node {
            data: [
                168, 152, 44, 137, 216, 9, 135, 251, 154, 81, 14, 37, 152, 30, 233, 23, 2, 6,
                190, 33, 175, 60, 142, 14, 179, 18, 239, 29, 51, 130, 231, 97,
            ],
            side: Side::right(),
        },
    ];

    let proof: Proof<4> = merkle_proof(leaves, 5, target, keccak_hash);

    assert(proof.len == 3);
    assert(proof.nodes[0] == expected_proof[0]);
    assert(proof.nodes[1] == expected_proof[1]);
    assert(proof.nodes[2] == expected_proof[2]);

    // Also verify the proof produces the correct root
    let expected_root = merkle_root(leaves, 5, keccak_hash);
    let computed_root = verify_proof(target, proof, keccak_hash);
    assert(computed_root == expected_root);
}

// =============================================================================
// TESTS - 4 leaves (power of 2) - Proof for leaf A (index 0)
// =============================================================================

#[test]
fn test_merkle_proof_leaves_base_2_make_proof() {
    // 4 leaves: [a, b, c, d]
    let leaves: [Leaf; 4] = [get_leaf_a(), get_leaf_b(), get_leaf_c(), get_leaf_d()];

    // Target: leaf A (index 0)
    let target = get_leaf_a();

    // Expected proof from Rust implementation
    let expected_proof: [Node; 2] = [
        Node {
            data: [
                181, 85, 61, 227, 21, 224, 237, 245, 4, 217, 21, 10, 248, 45, 175, 165, 196,
                102, 127, 166, 24, 237, 10, 111, 25, 198, 155, 65, 22, 108, 85, 16,
            ],
            side: Side::right(),
        },
        Node {
            data: [
                210, 83, 165, 45, 76, 176, 13, 226, 137, 94, 133, 242, 82, 158, 41, 118, 230,
                170, 170, 92, 24, 16, 107, 104, 171, 102, 129, 62, 20, 65, 86, 105,
            ],
            side: Side::right(),
        },
    ];

    let proof: Proof<4> = merkle_proof(leaves, 4, target, keccak_hash);

    assert(proof.len == 2);
    assert(proof.nodes[0] == expected_proof[0]);
    assert(proof.nodes[1] == expected_proof[1]);

    // Also verify the proof produces the correct root
    let expected_root = merkle_root(leaves, 4, keccak_hash);
    let computed_root = verify_proof(target, proof, keccak_hash);
    assert(computed_root == expected_root);
}

// =============================================================================
// TESTS - Additional coverage
// =============================================================================

#[test]
fn test_merkle_proof_2_leaves_first() {
    let leaves: [Leaf; 2] = [get_leaf_a(), get_leaf_b()];
    let target = get_leaf_a();
    let expected_root = merkle_root(leaves, 2, keccak_hash);

    let proof: Proof<2> = merkle_proof(leaves, 2, target, keccak_hash);

    assert(proof.len == 1);
    // First leaf (index 0) - sibling is on the right
    assert(proof.nodes[0].side == Side::right());
    assert(proof.nodes[0].data == get_leaf_b());

    let computed_root = verify_proof(target, proof, keccak_hash);
    assert(computed_root == expected_root);
}

#[test]
fn test_merkle_proof_2_leaves_second() {
    let leaves: [Leaf; 2] = [get_leaf_a(), get_leaf_b()];
    let target = get_leaf_b();
    let expected_root = merkle_root(leaves, 2, keccak_hash);

    let proof: Proof<2> = merkle_proof(leaves, 2, target, keccak_hash);

    assert(proof.len == 1);
    // Second leaf (index 1) - sibling is on the left
    assert(proof.nodes[0].side == Side::left());
    assert(proof.nodes[0].data == get_leaf_a());

    let computed_root = verify_proof(target, proof, keccak_hash);
    assert(computed_root == expected_root);
}

#[test]
fn test_merkle_proof_single_leaf() {
    let leaves: [Leaf; 1] = [get_leaf_a()];
    let target = get_leaf_a();

    let proof: Proof<1> = merkle_proof(leaves, 1, target, keccak_hash);

    // Single leaf tree has no proof nodes
    assert(proof.len == 0);
}

#[test]
fn test_merkle_proof_3_leaves() {
    let leaves: [Leaf; 3] = [get_leaf_a(), get_leaf_b(), get_leaf_c()];
    let target = get_leaf_c();
    let expected_root = merkle_root(leaves, 3, keccak_hash);

    let proof: Proof<3> = merkle_proof(leaves, 3, target, keccak_hash);

    let computed_root = verify_proof(target, proof, keccak_hash);
    assert(computed_root == expected_root);
}

#[test]
fn test_merkle_proof_4_leaves_all_positions() {
    let leaves: [Leaf; 4] = [get_leaf_a(), get_leaf_b(), get_leaf_c(), get_leaf_d()];
    let expected_root = merkle_root(leaves, 4, keccak_hash);

    // Test all 4 positions
    for i in 0..4 {
        let target = leaves[i];
        let proof: Proof<4> = merkle_proof(leaves, 4, target, keccak_hash);
        let computed_root = verify_proof(target, proof, keccak_hash);
        assert(computed_root == expected_root);
    }
}
