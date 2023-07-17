use array::ArrayTrait;

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct GameStats{
    block_number: u64,
    tick_number: u32,
}
