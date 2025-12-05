pub fn is_power_of_2(n: u32) -> bool {
    (n != 0) & ((n & (n - 1)) == 0)
}
