use crate::types::Hash;
use crate::side::Side;

pub struct Node {
    pub data: Hash,
    pub side: Side,
}

impl Node {
    pub fn new(data: Hash, side: Side) -> Self {
        Node { data, side }
    }
}
