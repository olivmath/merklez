pub type Hash = [u8; 32];
pub type Leaf = Hash;
pub type Root = Hash;
pub type HashFn = fn(Hash, Hash) -> Hash;
