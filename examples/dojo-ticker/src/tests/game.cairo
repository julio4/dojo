use traits::{Into, TryInto};
use core::result::ResultTrait;
use array::{ArrayTrait, SpanTrait};
use option::OptionTrait;
use box::BoxTrait;
use clone::Clone;
use debug::PrintTrait;

use starknet::{ContractAddress, syscalls::deploy_syscall};
use starknet::class_hash::{ClassHash, Felt252TryIntoClassHash};
use dojo::database::query::{IntoPartitioned, IntoPartitionedQuery};
use dojo::interfaces::{
    IComponentLibraryDispatcher, IComponentDispatcherTrait, ISystemLibraryDispatcher,
    ISystemDispatcherTrait
};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use dojo::test_utils::spawn_test_world;

use dojo_ticker::components::game::{game, Game, GameStateKind};
use dojo_ticker::systems::{init::init, start::start, tick::tick};

fn init_game() -> (IWorldDispatcher, u32) {
    let mut components = array::ArrayTrait::new();
    components.append(game::TEST_CLASS_HASH);

    let mut systems = array::ArrayTrait::new();
    systems.append(init::TEST_CLASS_HASH);
    systems.append(start::TEST_CLASS_HASH);
    systems.append(tick::TEST_CLASS_HASH);

    let world = spawn_test_world(components, systems);

    let mut init_calldata = array::ArrayTrait::<felt252>::new();
    let mut res = world.execute('init'.into(), init_calldata.span());
    assert(res.len() > 0, 'did not spawn');

    let game_id = serde::Serde::<u32>::deserialize(ref res).expect('init deserialization failed');

    (world, game_id)
}

fn get_game(world: IWorldDispatcher, game_id: u32) -> Game {
    let mut res = world.entity('Game'.into(), game_id.into(), 0, dojo::SerdeLen::<Game>::len());
    assert(res.len() > 0, 'game not found');

    serde::Serde::<Game>::deserialize(ref res).expect('game deserialization failed')
}

fn call_tick(world: IWorldDispatcher) {
    let mut tick_calldata = array::ArrayTrait::<felt252>::new();
    let mut res = world.execute('tick'.into(), tick_calldata.span());
}

fn call_start(world: IWorldDispatcher) {
    let mut start_calldata = array::ArrayTrait::<felt252>::new();
    let mut res = world.execute('start'.into(), start_calldata.span());
}

#[test]
#[available_gas(100000000)]
fn test_init_game() {
    let (world, game_id) = init_game();
    let game = get_game(world, game_id);
    assert(game.id == game_id, 'game id mismatch');
    assert(game.tick == 0, 'game tick mismatch');
    assert(game.state == GameStateKind::Idle(()), 'game state mismatch');
}

#[test]
#[available_gas(100000000)]
fn test_tick_idle_game() {
    let (world, game_id) = init_game();
    let initial_game = get_game(world, game_id);

    call_tick(world);

    // Idle so tick has no effect
    let game_after_tick = get_game(world, game_id);
    assert(game_after_tick == initial_game, 'game state mismatch');
}

#[test]
#[available_gas(100000000)]
fn test_tick_started_game() {
    let (world, game_id) = init_game();
    call_start(world);

    let initial_game = get_game(world, game_id);
    assert(initial_game.state == GameStateKind::Playing(()), 'game state mismatch');

    call_tick(world);

    let game_after_tick = get_game(world, game_id);
    assert(game_after_tick.tick == initial_game.tick + 1, 'game tick mismatch');
}
