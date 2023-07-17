use dojo::world::{Context, IWorldDispatcherTrait};
use serde::Serde;
use array::{ArrayTrait, SpanTrait};


fn emit(ctx: Context, name: felt252, values: Span<felt252>) {
    let mut keys = array::ArrayTrait::new();
    keys.append(name);
    ctx.world.emit(keys.span(), values);
}

#[derive(Drop, Serde)]
struct GameInfo {
    block_number: u64,
    tick_number: u32,
}

