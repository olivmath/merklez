# merklez

A Merkle Tree implementation in Noir - Port from the Rust library [merkletreers](https://github.com/olivmath/merkletreers).

## Features

- ✅ **No default hash function** - You provide your own hash function
- ✅ **No external dependencies** - Pure Noir implementation
- ✅ **Merkle root calculation** - Build merkle trees from leaves
- ✅ **Proof generation** - Generate merkle proofs for any leaf
- ✅ **Proof verification** - Verify merkle proofs against a root

## Installation

Add this to your `Nargo.toml`:

```toml
[dependencies]
merklez = { git = "https://github.com/olivmath/merklez" }
```

Or use it as a local dependency:

```toml
[dependencies]
merklez = { path = "../merklez" }
```

## Usage

### Basic Example

```noir
use merklez::{Hash, Leaf, Root, merkle_root, merkle_proof, merkle_proof_check, Proof};

// Define your own hash function
fn my_hash_function(left: Hash, right: Hash) -> Hash {
    // Your hash implementation here
    // Example: Poseidon, Pedersen, SHA256, etc.
    // This is just a placeholder
    let mut result: Hash = [0; 32];
    for i in 0..32 {
        result[i] = left[i] ^ right[i];
    }
    result
}

fn main() {
    // Create some leaves
    let mut leaf1: Hash = [0; 32];
    let mut leaf2: Hash = [0; 32];
    let mut leaf3: Hash = [0; 32];
    let mut leaf4: Hash = [0; 32];

    leaf1[0] = 1;
    leaf2[0] = 2;
    leaf3[0] = 3;
    leaf4[0] = 4;

    let leaves: [Leaf; 4] = [leaf1, leaf2, leaf3, leaf4];

    // Calculate merkle root
    let root = merkle_root(leaves, 4, my_hash_function);

    // Generate proof for leaf at index 0
    let proof: Proof<8> = merkle_proof(leaves, 4, 0, my_hash_function);

    // Verify the proof
    let computed_root = merkle_proof_check(proof, leaf1, my_hash_function);

    assert(computed_root == root);
}
```

### Using with Poseidon Hash

```noir
use merklez::{Hash, Leaf, merkle_root, merkle_proof, merkle_proof_check};
use std::hash::poseidon;

// Wrapper to convert Poseidon hash to our Hash type
fn poseidon_hash(left: Hash, right: Hash) -> Hash {
    // Convert to Field array
    let mut inputs: [Field; 64] = [0; 64];
    for i in 0..32 {
        inputs[i] = left[i] as Field;
        inputs[i + 32] = right[i] as Field;
    }

    // Hash with Poseidon
    let hash_field = poseidon::bn254::hash_64(inputs);

    // Convert back to bytes
    let mut result: Hash = [0; 32];
    let bytes = hash_field.to_be_bytes(32);
    for i in 0..32 {
        result[i] = bytes[i];
    }
    result
}

fn main() {
    let leaves: [Leaf; 4] = [...];
    let root = merkle_root(leaves, 4, poseidon_hash);
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
    leaves_len: u32,
    hash_fn: HashFn
) -> Root
```

**Parameters:**
- `leaves`: Array of leaf hashes
- `leaves_len`: Actual number of leaves (array might be larger)
- `hash_fn`: Custom hash function to combine two hashes

**Returns:** The merkle root hash

#### `merkle_proof<N, P>`

Generates a merkle proof for a specific leaf.

```noir
pub fn merkle_proof<let N: u32, let P: u32>(
    leaves: [Leaf; N],
    leaves_len: u32,
    leaf_index: u32,
    hash_fn: HashFn
) -> Proof<P>
```

**Parameters:**
- `leaves`: Array of all leaves
- `leaves_len`: Actual number of leaves
- `leaf_index`: Index of the leaf to prove
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

## Comparison with merkletreers

| Feature | merkletreers (Rust) | merklez (Noir) |
|---------|---------------------|----------------|
| Default hash | Keccak-256 | None (you provide) |
| Hash flexibility | Trait-based | Function parameter |
| Dynamic vectors | Yes | No (bounded arrays) |
| External deps | Yes (tiny-keccak) | None |
| Mixed trees | Yes | Not yet |

## Examples

See the `examples/` directory for more usage examples:

- `basic.nr` - Simple merkle tree
- `poseidon.nr` - Using Poseidon hash
- `large_tree.nr` - Larger tree with many leaves

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
