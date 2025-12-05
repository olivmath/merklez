# merklez Examples

This directory contains example usage of the merklez library.

## Examples

### basic_usage.nr

A simple example showing:
- How to create leaves
- How to calculate merkle root
- How to generate proofs
- How to verify proofs

This example uses a simple XOR-based hash function for demonstration. **Do not use this in production!**

### Running Examples

To run an example, you need to have Nargo installed. Then:

```bash
# Create a new Nargo project
nargo new my_merkle_project
cd my_merkle_project

# Copy the example code to src/main.nr
cp ../merklez/examples/basic_usage.nr src/main.nr

# Add merklez as a dependency in Nargo.toml
# [dependencies]
# merklez = { path = "../merklez" }

# Run the project
nargo execute
```

## Using with Cryptographic Hash Functions

For production use, you should use a cryptographically secure hash function optimized for zero-knowledge proofs:

### Poseidon (Recommended for zk-SNARKs)

```noir
use std::hash::poseidon;

fn poseidon_merkle_hash(left: Hash, right: Hash) -> Hash {
    // Convert bytes to Fields
    let mut inputs: [Field; 64] = [0; 64];
    for i in 0..32 {
        inputs[i] = left[i] as Field;
        inputs[i + 32] = right[i] as Field;
    }

    // Hash
    let result = poseidon::bn254::hash_64(inputs);

    // Convert back to bytes
    let mut hash: Hash = [0; 32];
    let bytes = result.to_be_bytes(32);
    for i in 0..32 {
        hash[i] = bytes[i];
    }
    hash
}
```

### Pedersen

```noir
use std::hash::pedersen_hash;

fn pedersen_merkle_hash(left: Hash, right: Hash) -> Hash {
    // Convert bytes to Fields
    let left_field = bytes_to_field(left);
    let right_field = bytes_to_field(right);

    // Hash
    let result = pedersen_hash([left_field, right_field]);

    // Convert back to bytes
    field_to_bytes(result)
}
```

### Keccak (like the original Rust library)

```noir
use std::hash::keccak256;

fn keccak_merkle_hash(left: Hash, right: Hash) -> Hash {
    let mut input: [u8; 64] = [0; 64];

    // Concatenate left and right
    for i in 0..32 {
        input[i] = left[i];
        input[i + 32] = right[i];
    }

    // Hash
    keccak256(input, 64)
}
```

## Performance Considerations

Different hash functions have different costs in terms of constraints:

| Hash Function | Constraints | Best For |
|---------------|-------------|----------|
| Poseidon | Low | zk-SNARKs (Recommended) |
| Pedersen | Low | Elliptic curve based systems |
| MiMC | Low | Alternative to Poseidon |
| Keccak | High | Ethereum compatibility |
| SHA256 | Very High | Bitcoin compatibility |

For Noir circuits, **Poseidon** is typically the best choice as it's optimized for zk-SNARKs and has the lowest constraint count.

## Tips

1. **Choose the right proof size**: The `Proof<N>` generic parameter should be at least `log2(num_leaves)` rounded up. For example:
   - 1-2 leaves: `Proof<1>`
   - 3-4 leaves: `Proof<2>`
   - 5-8 leaves: `Proof<3>`
   - 9-16 leaves: `Proof<4>`
   - etc.

2. **Pre-allocate arrays**: Noir requires fixed-size arrays, so plan your maximum tree size in advance.

3. **Batch verification**: If verifying multiple proofs, consider batching them in a single circuit for efficiency.

4. **Test thoroughly**: Always test your hash function integration with known test vectors.
