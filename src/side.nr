pub struct Side {
    pub value: u8,
}

impl Side {
    pub fn left() -> Self { Side { value: 0 } }
    pub fn right() -> Self { Side { value: 1 } }
    pub fn is_left(self) -> bool { self.value == 0 }
    pub fn is_right(self) -> bool { self.value == 1 }
    pub fn from_u8(value: u8) -> Self {
        assert((value == 0) | (value == 1), "Side value must be 0 or 1");
        Side { value }
    }
}
