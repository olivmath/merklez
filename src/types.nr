// =============================================================================
// TYPES - Core type definitions for the Merkle Tree library
// =============================================================================

/// A 32-byte hash value (standard cryptographic hash size)
pub type Hash = [u8; 32];

/// A leaf node in the Merkle Tree (alias for Hash)
pub type Leaf = Hash;

/// The root hash of a Merkle Tree (alias for Hash)
pub type Root = Hash;

/// Hash function signature: takes two hashes and produces a combined hash
/// This allows users to provide their own hash function (Poseidon, Pedersen, etc.)
pub type HashFn = fn(Hash, Hash) -> Hash;
