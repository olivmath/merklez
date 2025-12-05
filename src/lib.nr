// merklez - Merkle Tree implementation in Noir
// Port from merkletreers Rust library
// https://github.com/olivmath/merkletreers

// ============================================================================
// Type Definitions
// ============================================================================

/// Hash type - 32 bytes
pub type Hash = [u8; 32];

/// Leaf type - same as Hash
pub type Leaf = Hash;

/// Root type - same as Hash
pub type Root = Hash;

// ============================================================================
// Side Enum
// ============================================================================

/// Represents the position of a node in the tree
pub struct Side {
    pub value: u8,
}

impl Side {
    pub fn left() -> Self {
        Side { value: 0 }
    }

    pub fn right() -> Self {
        Side { value: 1 }
    }

    pub fn is_left(self) -> bool {
        self.value == 0
    }

    pub fn is_right(self) -> bool {
        self.value == 1
    }

    pub fn from_u8(value: u8) -> Self {
        assert((value == 0) | (value == 1), "Side value must be 0 or 1");
        Side { value }
    }
}

// ============================================================================
// Node Struct
// ============================================================================

/// Node represents a leaf in the merkle proof
pub struct Node {
    pub data: Hash,
    pub side: Side,
}

impl Node {
    pub fn new(data: Hash, side: Side) -> Self {
        Node { data, side }
    }
}

// ============================================================================
// Proof Type
// ============================================================================

/// Proof is a sequence of nodes that proves inclusion of a leaf
/// Using a bounded array instead of Vec
pub struct Proof<let N: u32> {
    pub nodes: [Node; N],
    pub len: u32,
}

impl<let N: u32> Proof<N> {
    pub fn new() -> Self {
        let empty_hash: Hash = [0; 32];
        let empty_node = Node::new(empty_hash, Side::left());
        Proof { nodes: [empty_node; N], len: 0 }
    }

    pub fn push(&mut self, node: Node) {
        assert(self.len < N, "Proof is full");
        self.nodes[self.len] = node;
        self.len += 1;
    }

    pub fn get(self, index: u32) -> Node {
        assert(index < self.len, "Index out of bounds");
        self.nodes[index]
    }
}

// ============================================================================
// Hash Function Type
// ============================================================================

/// Hash function type that takes two hashes and returns a new hash
/// Users must provide their own hash function implementation
pub type HashFn = fn(Hash, Hash) -> Hash;

// ============================================================================
// Helper Functions
// ============================================================================

/// Checks if a number is a power of 2
fn is_power_of_2(n: u32) -> bool {
    (n != 0) & ((n & (n - 1)) == 0)
}

// ============================================================================
// Merkle Root Calculation
// ============================================================================

/// Calculates the merkle root from an array of leaves
///
/// # Parameters
/// - leaves: Array of leaf hashes
/// - leaves_len: Actual number of leaves (array might be larger)
/// - hash_fn: Custom hash function to combine two hashes
///
/// # Returns
/// The merkle root hash
pub fn merkle_root<let N: u32>(leaves: [Leaf; N], leaves_len: u32, hash_fn: HashFn) -> Root {
    assert(leaves_len > 0, "Must have at least one leaf");
    assert(leaves_len <= N, "leaves_len exceeds array size");

    let mut result = leaves[0];

    // Handle single leaf case
    let single_leaf = leaves_len == 1;
    if !single_leaf {
        // Create working arrays for current level
        let zero_hash: Hash = [0; 32];
        let mut current_level: [Hash; N] = [zero_hash; N];
        let mut current_len = leaves_len;

        // Copy leaves to current level
        for i in 0..N {
            if i < leaves_len {
                current_level[i] = leaves[i];
            }
        }

        // Build tree level by level
        // Maximum number of levels is log2(N) + 1, but we use N as safe upper bound
        for _level in 0..N {
            if current_len > 1 {
                let mut next_level: [Hash; N] = [zero_hash; N];
                let mut next_len: u32 = 0;

                // Process pairs
                for i in 0..N {
                    let pair_index = i * 2;
                    if pair_index < current_len {
                        if pair_index + 1 < current_len {
                            // Hash pair
                            let left = current_level[pair_index];
                            let right = current_level[pair_index + 1];
                            next_level[next_len] = hash_fn(left, right);
                            next_len += 1;
                        } else {
                            // Odd one out, copy as is
                            next_level[next_len] = current_level[pair_index];
                            next_len += 1;
                        }
                    }
                }

                current_level = next_level;
                current_len = next_len;
            }
        }

        result = current_level[0];
    }

    result
}

// ============================================================================
// Merkle Proof Generation
// ============================================================================

/// Generates a merkle proof for a specific leaf
///
/// # Parameters
/// - leaves: Array of all leaves
/// - leaves_len: Actual number of leaves
/// - leaf_index: Index of the leaf to prove
/// - hash_fn: Custom hash function
///
/// # Returns
/// A Proof struct containing the path from leaf to root
pub fn merkle_proof<let N: u32, let P: u32>(
    leaves: [Leaf; N],
    leaves_len: u32,
    leaf_index: u32,
    hash_fn: HashFn,
) -> Proof<P> {
    assert(leaves_len > 0, "Must have at least one leaf");
    assert(leaf_index < leaves_len, "Leaf index out of bounds");

    let mut proof = Proof::new();

    // Handle single leaf case - no proof needed
    let single_leaf = leaves_len == 1;

    if !single_leaf {
        // Create working array for current level
        let zero_hash: Hash = [0; 32];
        let mut current_level: [Hash; N] = [zero_hash; N];
        let mut current_len = leaves_len;
        let mut current_index = leaf_index;

        // Copy leaves to current level
        for i in 0..N {
            if i < leaves_len {
                current_level[i] = leaves[i];
            }
        }

        // Build proof by traversing up the tree
        // Maximum number of levels is log2(N) + 1, but we use N as safe upper bound
        for _level in 0..N {
            if current_len > 1 {
                let mut next_level: [Hash; N] = [zero_hash; N];
                let mut next_len: u32 = 0;
                let mut new_index = current_index;

                // Process pairs
                for i in 0..N {
                    let pair_index = i * 2;
                    if pair_index < current_len {
                        if pair_index + 1 < current_len {
                            // Hash pair
                            let left = current_level[pair_index];
                            let right = current_level[pair_index + 1];

                            // If this pair contains our target index, add sibling to proof
                            if (current_index == pair_index) | (current_index == pair_index + 1) {
                                if current_index == pair_index {
                                    // Our node is on the left, sibling is on the right
                                    proof.push(Node::new(right, Side::right()));
                                } else {
                                    // Our node is on the right, sibling is on the left
                                    proof.push(Node::new(left, Side::left()));
                                }
                                new_index = next_len;
                            }

                            next_level[next_len] = hash_fn(left, right);
                            next_len += 1;
                        } else {
                            // Odd one out
                            next_level[next_len] = current_level[pair_index];
                            if current_index == pair_index {
                                new_index = next_len;
                            }
                            next_len += 1;
                        }
                    }
                }

                current_level = next_level;
                current_len = next_len;
                current_index = new_index;
            }
        }
    }

    proof
}

// ============================================================================
// Merkle Proof Verification
// ============================================================================

/// Verifies a merkle proof and returns the computed root
///
/// # Parameters
/// - proof: The proof to verify
/// - leaf: The leaf to verify
/// - hash_fn: Custom hash function
///
/// # Returns
/// The computed root hash (compare with expected root to verify)
pub fn merkle_proof_check<let P: u32>(proof: Proof<P>, leaf: Leaf, hash_fn: HashFn) -> Root {
    let mut current_hash = leaf;

    for i in 0..P {
        if i < proof.len {
            let node = proof.nodes[i];

            if node.side.is_right() {
                // Sibling is on the right
                current_hash = hash_fn(current_hash, node.data);
            } else {
                // Sibling is on the left
                current_hash = hash_fn(node.data, current_hash);
            }
        }
    }

    current_hash
}

// ============================================================================
// Tests
// ============================================================================

#[test]
fn test_side() {
    let left = Side::left();
    let right = Side::right();

    assert(left.is_left());
    assert(!left.is_right());
    assert(right.is_right());
    assert(!right.is_left());
}

#[test]
fn test_power_of_2() {
    assert(is_power_of_2(1));
    assert(is_power_of_2(2));
    assert(is_power_of_2(4));
    assert(is_power_of_2(8));
    assert(!is_power_of_2(3));
    assert(!is_power_of_2(5));
    assert(!is_power_of_2(7));
}

// Example hash function for testing (simple XOR - NOT cryptographically secure!)
fn test_hash_fn(left: Hash, right: Hash) -> Hash {
    let mut result: Hash = [0; 32];
    for i in 0..32 {
        result[i] = left[i] ^ right[i];
    }
    result
}

#[test]
fn test_merkle_root_single_leaf() {
    let leaves: [Leaf; 1] = [[1; 32]];
    let root = merkle_root(leaves, 1, test_hash_fn);
    assert(root == [1; 32]);
}

#[test]
fn test_merkle_root_two_leaves() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;

    let leaves: [Leaf; 2] = [leaf1, leaf2];
    let root = merkle_root(leaves, 2, test_hash_fn);

    // Root should be XOR of leaf1 and leaf2
    let mut expected: Hash = [0; 32];
    expected[0] = 1 ^ 2;
    assert(root == expected);
}

#[test]
fn test_merkle_proof_and_verify() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    leaf1[0] = 1;
    leaf2[0] = 2;

    let leaves: [Leaf; 2] = [leaf1, leaf2];
    let root = merkle_root(leaves, 2, test_hash_fn);

    // Generate proof for leaf1
    let proof: Proof<8> = merkle_proof(leaves, 2, 0, test_hash_fn);

    // Verify proof
    let computed_root = merkle_proof_check(proof, leaf1, test_hash_fn);
    assert(computed_root == root);
}

#[test]
fn test_merkle_root_four_leaves() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    let mut leaf3: Hash = [0; 32];
    let mut leaf4: Hash = [0; 32];

    leaf1[0] = 1;
    leaf2[0] = 2;
    leaf3[0] = 3;
    leaf4[0] = 4;

    let leaves: [Leaf; 4] = [leaf1, leaf2, leaf3, leaf4];
    let root = merkle_root(leaves, 4, test_hash_fn);

    // Manually calculate expected root
    let hash12 = test_hash_fn(leaf1, leaf2);
    let hash34 = test_hash_fn(leaf3, leaf4);
    let expected = test_hash_fn(hash12, hash34);

    assert(root == expected);
}

#[test]
fn test_merkle_proof_four_leaves() {
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    let mut leaf3: Hash = [0; 32];
    let mut leaf4: Hash = [0; 32];

    leaf1[0] = 1;
    leaf2[0] = 2;
    leaf3[0] = 3;
    leaf4[0] = 4;

    let leaves: [Leaf; 4] = [leaf1, leaf2, leaf3, leaf4];
    let root = merkle_root(leaves, 4, test_hash_fn);

    // Test proof for each leaf
    let proof0: Proof<8> = merkle_proof(leaves, 4, 0, test_hash_fn);
    let proof1: Proof<8> = merkle_proof(leaves, 4, 1, test_hash_fn);
    let proof2: Proof<8> = merkle_proof(leaves, 4, 2, test_hash_fn);
    let proof3: Proof<8> = merkle_proof(leaves, 4, 3, test_hash_fn);

    assert(merkle_proof_check(proof0, leaf1, test_hash_fn) == root);
    assert(merkle_proof_check(proof1, leaf2, test_hash_fn) == root);
    assert(merkle_proof_check(proof2, leaf3, test_hash_fn) == root);
    assert(merkle_proof_check(proof3, leaf4, test_hash_fn) == root);
}
