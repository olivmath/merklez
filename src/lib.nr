// =============================================================================
// MERKLEZ - A Merkle Tree library for Noir
// =============================================================================
//
// This library provides a complete Merkle tree implementation including:
// - Root calculation from leaves
// - Proof generation for any leaf
// - Proof verification
// - High-level MerkleTree API
//
// Design principles:
// - No default hash function (users provide their own: Poseidon, Pedersen, etc.)
// - Bounded arrays (Noir requirement for compile-time sizes)
// - Clean separation of concerns
//
// =============================================================================

// -----------------------------------------------------------------------------
// Core type definitions
// -----------------------------------------------------------------------------
mod types;

// -----------------------------------------------------------------------------
// Data structures
// -----------------------------------------------------------------------------
mod side;   // Left/right indicator for proof nodes
mod node;   // Single node in a Merkle proof
mod proof;  // Collection of proof nodes

// -----------------------------------------------------------------------------
// Utility functions
// -----------------------------------------------------------------------------
mod utils;

// -----------------------------------------------------------------------------
// Core Merkle operations
// -----------------------------------------------------------------------------
mod merkle; // merkle_root, merkle_proof, merkle_proof_check

// -----------------------------------------------------------------------------
// High-level API
// -----------------------------------------------------------------------------
mod tree;   // MerkleTree struct with convenient methods

// =============================================================================
// PUBLIC EXPORTS
// =============================================================================

// Types
pub use types::{Hash, Leaf, Root, HashFn};

// Data structures
pub use side::Side;
pub use node::Node;
pub use proof::Proof;

// Core functions
pub use merkle::{merkle_root, merkle_proof, merkle_proof_check};

// High-level API
pub use tree::MerkleTree;
