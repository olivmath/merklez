// use crate::side::Side;
// use crate::types::{HashFn, Leaf, Proof};
// use crate::merkle_root::merkle_root;
// use crate::node::Node;

// pub fn merkle_proof<let N: u32, let P: u32>(leaves: [Leaf; N], leaf: Leaf, hash_fn: HashFn) -> Proof<P> {
//     let mut proof: Proof<P> = Proof { nodes: [Node { data: [0u8; 32], side: Side::left() }; P], len: 0u32 };

//     let mut level: [Leaf; N] = leaves;
//     let mut curr_len: u32 = N;

//     let mut idx_opt: u32 = 0u32;
//     let mut found: bool = false;
//     for i in 0..N {
//         if i < curr_len {
//             if level[i] == leaf {
//                 idx_opt = i;
//                 found = true;
//             }
//         }
//     }
//     assert(found);

//     let mut idx: u32 = idx_opt;

//     // Work buffers for computing subtree roots
//     let mut seg_left: [Leaf; N] = leaves;
//     let mut seg_right: [Leaf; N] = leaves;

//     let mut done: bool = false;
//     for _p in 0..N {
//         if done {
//         } else if curr_len <= 1u32 {
//             done = true;
//         } else if curr_len == 2u32 {
//             if idx == 1u32 {
//                 proof.nodes[proof.len] = Node { data: level[0u32], side: Side::left() };
//                 proof.len += 1u32;
//             } else {
//                 proof.nodes[proof.len] = Node { data: level[1u32], side: Side::right() };
//                 proof.len += 1u32;
//             }
//             done = true;
//         } else {
//             let half_size: u32 = curr_len / 2u32;
//             // split current level into left/right segments in work arrays
//             for j in 0..N {
//                 if j < half_size {
//                     seg_left[j] = level[j];
//                 }
//             }
//             for j in 0..N {
//                 let r_idx = j + half_size;
//                 if r_idx < curr_len {
//                     seg_right[j] = level[r_idx];
//                 }
//             }

//             if idx < half_size {
//                 let right_root = merkle_root::<N>(seg_right, curr_len - half_size, hash_fn);
//                 proof.nodes[proof.len] = Node { data: right_root, side: Side::right() };
//                 proof.len += 1u32;
//                 // descend into left
//                 for j in 0..N {
//                     if j < half_size { level[j] = seg_left[j]; }
//                 }
//                 curr_len = half_size;
//                 // idx unchanged
//             } else {
//                 let left_root = merkle_root::<N>(seg_left, half_size, hash_fn);
//                 proof.nodes[proof.len] = Node { data: left_root, side: Side::left() };
//                 proof.len += 1u32;
//                 // descend into right
//                 for j in 0..N {
//                     let r_idx = j + half_size;
//                     if r_idx < curr_len { level[j] = level[r_idx]; }
//                 }
//                 idx = idx - half_size;
//                 curr_len = curr_len - half_size;
//             }
//         }
//     }

//     // reverse proof to be bottom-up
//     let mut out: Proof<P> = Proof { nodes: [Node { data: [0u8; 32], side: Side::left() }; P], len: 0u32 };
//     let mut k: u32 = proof.len;
//     for _i in 0..P {
//         if k == 0u32 {
//         } else {
//             k -= 1u32;
//             out.nodes[out.len] = proof.nodes[k];
//             out.len += 1u32;
//         }
//     }

//     out
// }
