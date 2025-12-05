use crate::types::Hash;

pub fn test_hash_fn(left: Hash, right: Hash) -> Hash {
    let mut result: Hash = [0; 32];
    for i in 0..32 { result[i] = left[i] ^ right[i]; }
    result
}
