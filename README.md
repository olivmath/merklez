# merklez

[![CI Tests](https://github.com/olivmath/merklez/actions/workflows/test.yml/badge.svg)](https://github.com/olivmath/merklez/actions/workflows/test.yml)

A Merkle Tree implementation in Noir - Port from the Rust library [merkletreers](https://github.com/olivmath/merkletreers).

## Features

- **No default hash function** - You provide your own hash function (Poseidon, Pedersen, SHA256, etc.)
- **No external dependencies** - Pure Noir implementation
- **Merkle root calculation** - Build merkle trees from leaves
- **Proof generation** - Generate merkle proofs for any leaf
- **Proof verification** - Verify merkle proofs against a root
- **High-level API** - `MerkleTree` struct for convenient usage

## Installation

Add this to your `Nargo.toml`:

```toml
[dependencies]
merklez = { tag = "0.4.0", git = "https://github.com/olivmath/merklez", directory = "merklez" }
```

## Quick Start

### 1. Calculate Merkle Root

```noir
use merklez::{MerkleTree, Hash, Leaf};

// Define your hash function
fn my_hash(left: Hash, right: Hash) -> Hash {
    // Use your preferred hash: Poseidon, Pedersen, SHA256, etc.
    let mut result: Hash = [0; 32];
    for i in 0..32 {
        result[i] = left[i] ^ right[i];
    }
    result
}

fn main() {
    // Create leaves
    let mut leaf_a: Hash = [0; 32]; leaf_a[0] = 1;
    let mut leaf_b: Hash = [0; 32]; leaf_b[0] = 2;
    let mut leaf_c: Hash = [0; 32]; leaf_c[0] = 3;
    let mut leaf_d: Hash = [0; 32]; leaf_d[0] = 4;

    let leaves: [Leaf; 4] = [leaf_a, leaf_b, leaf_c, leaf_d];

    // Build tree and get root
    let tree = MerkleTree::new(leaves, my_hash);
    let root = tree.root; // The merkle root hash
}
```

### 2. Generate Merkle Proof

```noir
use merklez::{MerkleTree, Proof, Hash, Leaf};

fn main() {
    // ... create leaves and tree as above ...
    let tree = MerkleTree::new(leaves, my_hash);

    // Generate proof for a specific leaf
    let proof: Proof<8> = tree.make_proof(leaf_c);

    // The proof contains sibling nodes needed to reconstruct the root
    // proof.len -> number of nodes in proof path
    // proof.nodes -> array of Node { data: Hash, side: Side }
}
```

### 3. Verify Merkle Proof

```noir
use merklez::{MerkleTree, Proof, Hash, Leaf};

fn main() {
    // ... create tree and proof ...
    let tree = MerkleTree::new(leaves, my_hash);
    let proof: Proof<8> = tree.make_proof(leaf_c);

    // Verify proof against the tree
    let is_valid: bool = tree.verify_merkle_proof(leaf_c, proof);
    assert(is_valid);
}
```

## Proof Types

### Membership Proof (Public Root)

Prove that an element belongs to a set without revealing other elements. The root is public, leaf and proof are private.

```noir
use merklez::{Proof, merkle_proof_check, Hash};

// Circuit inputs: root is public, leaf and proof are private
fn main(pub root: Hash, leaf: Hash, proof: Proof<8>) {
    // Verify the leaf is part of the tree with this root
    let computed_root = merkle_proof_check(proof, leaf, my_hash);
    assert(computed_root == root);
}
```

**Use cases:**
- Whitelist verification (prove you're on an allowlist)
- Airdrop eligibility (prove you qualify without revealing all recipients)
- Anonymous voting (prove you're a registered voter)

### Membership Proof (Private Root)

Both root and leaf are private. Useful for proving knowledge of a valid set membership.

```noir
use merklez::{Proof, merkle_proof_check, Hash};

fn main(leaf: Hash, proof: Proof<8>, root: Hash) {
    // All inputs are private
    let computed_root = merkle_proof_check(proof, leaf, my_hash);
    assert(computed_root == root);
}
```

### Static Verification (Without Tree Instance)

Verify a proof when you only have the root hash (no need to rebuild the tree).

```noir
use merklez::{MerkleTree, Proof, Hash, Leaf};

fn main(root: Hash, leaf: Hash, proof: Proof<8>) {
    // Static verification - no tree instance needed
    let is_valid = MerkleTree::<4>::static_verify_merkle_proof(
        leaf,
        proof,
        root,
        my_hash
    );
    assert(is_valid);
}
```

### Exclusion Proof (Non-Membership)

Prove an element is NOT in a sorted merkle tree by showing its position would be between two adjacent leaves.

```noir
use merklez::{MerkleTree, Proof, Hash, Leaf};

fn main(
    pub root: Hash,
    target: Hash,           // Element to prove is NOT in tree
    left_neighbor: Hash,    // Element just before target position
    right_neighbor: Hash,   // Element just after target position
    proof_left: Proof<8>,
    proof_right: Proof<8>
) {
    // Verify both neighbors are in the tree
    let left_valid = merkle_proof_check(proof_left, left_neighbor, my_hash);
    let right_valid = merkle_proof_check(proof_right, right_neighbor, my_hash);
    assert(left_valid == root);
    assert(right_valid == root);

    // Verify target would be between neighbors (tree must be sorted)
    assert(left_neighbor < target);
    assert(target < right_neighbor);
}
```

## Low-Level API

For more control, use the functions directly instead of `MerkleTree`:

```noir
use merklez::{merkle_root, merkle_proof, merkle_proof_check, Proof, Hash, Leaf};

fn main() {
    let leaves: [Leaf; 4] = [leaf_a, leaf_b, leaf_c, leaf_d];

    // Calculate root directly
    let root = merkle_root(leaves, my_hash);

    // Generate proof for leaf_c
    let proof: Proof<2> = merkle_proof(leaves, leaf_c, my_hash);

    // Verify proof
    let computed = merkle_proof_check(proof, leaf_c, my_hash);
    assert(computed == root);
}
```

## API Reference

### Types

- **`Hash`**: `[u8; 32]` - 32-byte hash
- **`Leaf`**: `Hash` - Leaf node hash
- **`Root`**: `Hash` - Root hash
- **`HashFn`**: `fn(Hash, Hash) -> Hash` - Hash function type

### Structs

#### `Side`
Represents the position of a node in the tree.

- `Side::left()` - Create a left side marker
- `Side::right()` - Create a right side marker
- `is_left()` - Check if left
- `is_right()` - Check if right

#### `Node`
Represents a node in the merkle proof.

```noir
struct Node {
    pub data: Hash,
    pub side: Side
}
```

#### `Proof<N>`
Represents a merkle proof with maximum size N.

```noir
struct Proof<let N: u32> {
    pub nodes: [Node; N],
    pub len: u32
}
```

Methods:
- `new()` - Create empty proof
- `push(node: Node)` - Add node to proof
- `get(index: u32) -> Node` - Get node at index

### Functions

#### `merkle_root<N>`

Calculates the merkle root from an array of leaves.

```noir
pub fn merkle_root<let N: u32>(
    leaves: [Leaf; N],
    hash_fn: HashFn
) -> Root
```

**Type Parameters:**
- `N`: Number of leaves in the tree

**Parameters:**
- `leaves`: Array of leaf hashes
- `hash_fn`: Custom hash function to combine two hashes

**Returns:** The merkle root hash

#### `merkle_proof<N, P>`

Generates a merkle proof for a specific leaf.

```noir
pub fn merkle_proof<let N: u32, let P: u32>(
    leaves: [Leaf; N],
    leaf: Leaf,
    hash_fn: HashFn
) -> Proof<P>
```

**Type Parameters:**
- `N`: Number of leaves in the tree
- `P`: Proof capacity (use `ceil(log2(N))`): N=2→P=1, N=3-4→P=2, N=5-8→P=3, N=9-16→P=4

**Parameters:**
- `leaves`: Array of all leaves
- `leaf`: The leaf to generate a proof for
- `hash_fn`: Custom hash function

**Returns:** A Proof struct containing the path from leaf to root

#### `merkle_proof_check<P>`

Verifies a merkle proof and returns the computed root.

```noir
pub fn merkle_proof_check<let P: u32>(
    proof: Proof<P>,
    leaf: Leaf,
    hash_fn: HashFn
) -> Root
```

**Parameters:**
- `proof`: The proof to verify
- `leaf`: The leaf to verify
- `hash_fn`: Custom hash function

**Returns:** The computed root hash (compare with expected root to verify)

## Design Decisions

### Why No Default Hash Function?

Zero-knowledge proof systems like Noir work best with specific hash functions optimized for their constraint systems. Different applications may need different hash functions:

- **Poseidon**: Optimized for zk-SNARKs
- **Pedersen**: Good for certain circuit optimizations
- **Mimc**: Another zk-friendly hash
- **SHA256**: Standard but expensive in circuits

By not providing a default, we ensure you choose the right hash for your use case.

### Why No External Dependencies?

To keep the library minimal and auditable. You can easily integrate with any hash function from the Noir standard library or your own implementation.

### Bounded Arrays Instead of Vectors

Noir doesn't have dynamic vectors like Rust. We use bounded arrays with a length field to simulate dynamic behavior. You need to specify maximum sizes at compile time:

```noir
// Proof can contain maximum 8 nodes
let proof: Proof<8> = merkle_proof(...);

// Tree can have maximum 16 leaves
let leaves: [Leaf; 16] = [...];
```

## Testing

Run the tests with:

```bash
nargo test
```


## Examples

See the [`examples/`](./examples/) directory for more usage examples:

**Basic Usage** (`how_to_use/`):
- `merkle_root.nr` - Calculate merkle root from leaves
- `merkle_proof.nr` - Generate merkle proofs for elements
- `merkle_proof_check.nr` - Verify proofs using low-level API
- `merkle_verify.nr` - Verify merkle proofs using high-level API

**ZK Proof Patterns** (`how_to_proof/`):
- `membership_public_root.nr` - Membership proof with public root (whitelist, airdrops, voting)

## Contributing

Contributions are welcome! Please open an issue or PR.

## License

Same as original merkletreers library.

## Credits

This library is a port of [merkletreers](https://github.com/olivmath/merkletreers) by [@olivmath](https://github.com/olivmath).

## References

- [merkletreers](https://github.com/olivmath/merkletreers) - Original Rust implementation
- [Noir Language](https://noir-lang.org/) - The Noir documentation
- [Merkle Trees](https://en.wikipedia.org/wiki/Merkle_tree) - Wikipedia article
