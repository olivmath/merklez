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
pub mod types;

// -----------------------------------------------------------------------------
// Data structures
// -----------------------------------------------------------------------------

// Left/right indicator for proof nodes
mod side;
// Single node in a Merkle proof
mod node;

// -----------------------------------------------------------------------------
// Utility functions
// -----------------------------------------------------------------------------
mod utils;

// -----------------------------------------------------------------------------
// Core Merkle operations
// -----------------------------------------------------------------------------
pub mod merkle_root;
