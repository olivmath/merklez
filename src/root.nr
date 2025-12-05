use crate::types::{Hash, Leaf, Root, HashFn};

pub fn merkle_root<let N: u32>(leaves: [Leaf; N], leaves_len: u32, hash_fn: HashFn) -> Root {
    assert(leaves_len > 0, "Must have at least one leaf");
    assert(leaves_len <= N, "leaves_len exceeds array size");

    let mut result = leaves[0];

    let single_leaf = leaves_len == 1;
    if !single_leaf {
        let zero_hash: Hash = [0; 32];
        let mut current_level: [Hash; N] = [zero_hash; N];
        let mut current_len = leaves_len;

        for i in 0..N {
            if i < leaves_len {
                current_level[i] = leaves[i];
            }
        }

        for _level in 0..N {
            if current_len > 1 {
                let mut next_level: [Hash; N] = [zero_hash; N];
                let mut next_len: u32 = 0;

                for i in 0..N {
                    let pair_index = i * 2;
                    if pair_index < current_len {
                        if pair_index + 1 < current_len {
                            let left = current_level[pair_index];
                            let right = current_level[pair_index + 1];
                            next_level[next_len] = hash_fn(left, right);
                            next_len += 1;
                        } else {
                            next_level[next_len] = current_level[pair_index];
                            next_len += 1;
                        }
                    }
                }

                current_level = next_level;
                current_len = next_len;
            }
        }

        result = current_level[0];
    }

    result
}
