# merklez Examples

This directory contains practical examples of using the merklez library.

## Directory Structure

```
examples/
├── how_to_use/           # Basic usage examples
│   ├── merkle_root.nr    # Calculate merkle root
│   ├── merkle_proof.nr   # Generate merkle proofs
│   └── merkle_verify.nr  # Verify merkle proofs
├── how_to_proof/         # ZK proof patterns
│   └── membership_public_root.nr  # Membership proof with public root
└── README.md
```

## How to Use Examples

### `how_to_use/merkle_root.nr`

Calculate the merkle root from a list of leaves:

```noir
use merklez::{MerkleTree, Hash, Leaf};

fn main() {
    // Create leaves (hashes of your data)
    let leaves: [Leaf; 5] = [
        sha256("a"),
        sha256("b"),
        sha256("c"),
        sha256("d"),
        sha256("e")
    ];

    // Build tree
    let tree = MerkleTree::new(leaves, sha256);

    // Get the root
    let root: Hash = tree.root;
}
```

### `how_to_use/merkle_proof.nr`

Generate a merkle proof for a specific leaf:

```noir
use merklez::{MerkleTree, Proof, Node, Side, Hash, Leaf};

fn main() {
    let leaves: [Leaf; 5] = [...];
    let tree = MerkleTree::new(leaves, sha256);

    // Generate proof for element 'c'
    let leaf_c: Hash = sha256("c");
    let proof: Proof<8> = tree.make_proof(leaf_c);

    // The proof contains:
    // - proof.nodes: Array of sibling hashes
    // - proof.len: Number of nodes in the proof
    // Each node has:
    // - node.data: The sibling hash
    // - node.side: Side::left() or Side::right()
}
```

### `how_to_use/merkle_verify.nr`

Verify a merkle proof:

```noir
use merklez::{MerkleTree, Proof, Hash, Leaf};

fn main() {
    let leaves: [Leaf; 5] = [...];
    let tree = MerkleTree::new(leaves, sha256);

    let leaf_c: Hash = sha256("c");
    let proof: Proof<8> = tree.make_proof(leaf_c);

    // Method 1: Verify using tree instance
    let is_valid: bool = tree.verify_merkle_proof(leaf_c, proof);
    assert(is_valid);

    // Method 2: Static verification (no tree needed)
    let is_valid_static = MerkleTree::<5>::static_verify_merkle_proof(
        leaf_c,
        proof,
        tree.root,
        sha256
    );
    assert(is_valid_static);
}
```

## How to Proof Examples

### `how_to_proof/membership_public_root.nr`

**Membership Proof with Public Root** - The most common ZK pattern.

This proves that a secret leaf belongs to a merkle tree with a known (public) root, without revealing which leaf it is.

```noir
use merklez::{Proof, merkle_proof_check, Hash};

// pub root = public input (verifier knows this)
// leaf = private input (only prover knows)
// proof = private input (only prover knows)
fn main(pub root: Hash, leaf: Hash, proof: Proof<3>) {
    let computed = merkle_proof_check(proof, leaf, sha256);
    assert(computed == root);
}
```

**Use cases:**
- **Whitelist verification**: Prove you're on an allowlist without revealing your identity
- **Airdrop claims**: Prove eligibility without exposing the full recipient list
- **Anonymous voting**: Prove you're a registered voter without revealing who you are
- **Private membership**: Prove membership in a group without revealing the group members

## Hash Function Examples

### Poseidon (Recommended for ZK)

```noir
use std::hash::poseidon;

fn poseidon_hash(left: Hash, right: Hash) -> Hash {
    let mut inputs: [Field; 64] = [0; 64];
    for i in 0..32 {
        inputs[i] = left[i] as Field;
        inputs[i + 32] = right[i] as Field;
    }

    let result = poseidon::bn254::hash_64(inputs);

    let mut hash: Hash = [0; 32];
    let bytes = result.to_be_bytes(32);
    for i in 0..32 {
        hash[i] = bytes[i];
    }
    hash
}
```

### Keccak256 (Ethereum compatible)

```noir
use std::hash::keccak256;

fn keccak_hash(left: Hash, right: Hash) -> Hash {
    let mut input: [u8; 64] = [0; 64];
    for i in 0..32 {
        input[i] = left[i];
        input[i + 32] = right[i];
    }
    keccak256(input, 64)
}
```

### Pedersen

```noir
use std::hash::pedersen_hash;

fn pedersen_merkle_hash(left: Hash, right: Hash) -> Hash {
    let left_field = bytes_to_field(left);
    let right_field = bytes_to_field(right);
    let result = pedersen_hash([left_field, right_field]);
    field_to_bytes(result)
}
```

## Performance Guide

| Hash Function | Constraints | Best For |
|---------------|-------------|----------|
| Poseidon | ~300 | zk-SNARKs (Recommended) |
| Pedersen | ~1000 | Elliptic curve systems |
| Keccak256 | ~30000 | Ethereum compatibility |
| SHA256 | ~25000 | Bitcoin compatibility |

## Proof Size Guide

Choose `Proof<N>` where N >= ceil(log2(num_leaves)):

| Leaves | Minimum N |
|--------|-----------|
| 1-2 | 1 |
| 3-4 | 2 |
| 5-8 | 3 |
| 9-16 | 4 |
| 17-32 | 5 |
| 33-64 | 6 |
| 65-128 | 7 |
| 129-256 | 8 |

**Tip:** Use a larger N than minimum for safety margin.

## Running Examples

```bash
# Create a new project
nargo new my_project
cd my_project

# Add merklez to Nargo.toml
echo '[dependencies]
merklez = { git = "https://github.com/olivmath/merklez" }' >> Nargo.toml

# Copy example code to src/main.nr
cp /path/to/merklez/examples/how_to_use/merkle_root.nr src/main.nr

# Execute
nargo execute
```
