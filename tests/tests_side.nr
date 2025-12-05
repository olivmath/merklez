use crate::side::Side;

#[test]
fn test_side() {
    let left = Side::left();
    let right = Side::right();
    assert(left.is_left());
    assert(!left.is_right());
    assert(right.is_right());
    assert(!right.is_left());
}
