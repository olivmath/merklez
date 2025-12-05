use crate::node::Node;
use crate::side::Side;
use crate::types::Hash;

pub struct Proof<let N: u32> {
    pub nodes: [Node; N],
    pub len: u32,
}

impl<let N: u32> Proof<N> {
    pub fn new() -> Self {
        let empty_hash: Hash = [0; 32];
        let empty_node = Node::new(empty_hash, Side::left());
        Proof { nodes: [empty_node; N], len: 0 }
    }

    pub fn push(&mut self, node: Node) {
        assert(self.len < N, "Proof is full");
        self.nodes[self.len] = node;
        self.len += 1;
    }

    pub fn get(self, index: u32) -> Node {
        assert(index < self.len, "Index out of bounds");
        self.nodes[index]
    }
}
