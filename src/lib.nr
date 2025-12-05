mod types;
mod side;
mod node;
mod proof;
mod utils;
mod root;
mod proof_gen;
mod proof_check;
mod tree;

pub use types::{Hash, Leaf, Root, HashFn};
pub use side::Side;
pub use node::Node;
pub use proof::Proof;
pub use root::merkle_root;
pub use proof_gen::merkle_proof;
pub use proof_check::merkle_proof_check;
pub use tree::MerkleTree;
