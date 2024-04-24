use crate::ldk::lightning::Lighting;

pub fn add_two(left: usize, right: usize) -> usize {
    left + right
}

pub fn test_one() -> String {
    Lighting::default().test_lightning()
}
