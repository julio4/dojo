#[system]
mod initialize {
    use dojo_examples::components::GameInfo;
    use dojo::world::Context;
    use array::ArrayTrait;
    use traits::Into;
    use starknet::info::get_block_number;

    // initialize game
    fn execute(ctx: Context) {
        set !(ctx.world, ctx.origin.into(), (GameInfo {block_number: get_block_number(), tick_number: 0}));

        let mut keys = ArrayTrait::new();
        keys.append('StartGame');
        let mut values = ArrayTrait::new();
        values.append(1);

        ctx.world.emit(keys.span(),values.span());

        return ();
    }
}

trait IGame<T> {
    fn tick(ref self: T);
}

#[system]
mod run_game {
    use super::IGame;
    use dojo::world::Context;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        GameInfoUpdate: GameInfoUpdate
    }

    #[derive(Drop, starknet::Event)]
    struct GameInfoUpdate {
        block_number: u64,
        tick_number: u64,
    }

    fn execute(ctx: Context) {
            return ();
    }

    impl GameImpl of IGame<Context>{
        fn tick(ref self: Context){
            // do stuff
            return ();
        }  
    }
}


// example game 
#[system]
mod spawn {
    use array::ArrayTrait;
    use traits::Into;
    use dojo::world::Context;

    use dojo_examples::components::Position;
    use dojo_examples::components::Moves;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StartGame: StartGame,

    }

    #[derive(Drop, starknet::Event)]
    struct StartGame {
        start_game: bool,
    }

    fn execute(ctx: Context) {
        set !(
            ctx.world,
            ctx.origin.into(),
            (Moves { remaining: 10 }, Position { x: 0, y: 0 }, )
        );

        let mut keys = ArrayTrait::new();
        keys.append('StartGame');
        let mut values = ArrayTrait::new();
        values.append(1);

        ctx.world.emit(keys.span(),values.span());
        return ();
    }
}

#[system]
mod move {
    use array::ArrayTrait;
    use traits::Into;
    use dojo::world::Context;

    use dojo_examples::components::Position;
    use dojo_examples::components::Moves;

    #[derive(Serde, Drop)]
    enum Direction {
        Left: (),
        Right: (),
        Up: (),
        Down: (),
    }

    impl DirectionIntoFelt252 of Into<Direction, felt252> {
        fn into(self: Direction) -> felt252 {
            match self {
                Direction::Left(()) => 0,
                Direction::Right(()) => 1,
                Direction::Up(()) => 2,
                Direction::Down(()) => 3,
            }
        }
    }

    fn execute(ctx: Context, direction: Direction) {
        let (position, moves) = get !(ctx.world, ctx.origin.into(), (Position, Moves));
        let next = next_position(position, direction);
        set !(
            ctx.world,
            ctx.origin.into(),
            (Moves { remaining: moves.remaining - 1 }, Position { x: next.x, y: next.y }, )
        );
        return ();
    }

    fn next_position(position: Position, direction: Direction) -> Position {
        match direction {
            Direction::Left(()) => {
                Position { x: position.x - 1, y: position.y }
            },
            Direction::Right(()) => {
                Position { x: position.x + 1, y: position.y }
            },
            Direction::Up(()) => {
                Position { x: position.x, y: position.y + 1 }
            },
            Direction::Down(()) => {
                Position { x: position.x, y: position.y - 1 }
            },
        }
    }
}

#[cfg(test)]
mod tests {
    use core::traits::{Into, Default};
    use array::ArrayTrait;

    use dojo::world::IWorldDispatcherTrait;

    use dojo::test_utils::spawn_test_world;

    use dojo_examples::components::position;
    use dojo_examples::components::Position;
    use dojo_examples::components::moves;
    use dojo_examples::components::Moves;
    use dojo_examples::systems::spawn;
    use dojo_examples::systems::move;

    #[test]
    #[available_gas(30000000)]
    fn test_move() {
        let caller = starknet::contract_address_const::<0x0>();

        // components
        let mut components: Array = Default::default();
        components.append(position::TEST_CLASS_HASH);
        components.append(moves::TEST_CLASS_HASH);
        // systems
        let mut systems: Array = Default::default();
        systems.append(spawn::TEST_CLASS_HASH);
        systems.append(move::TEST_CLASS_HASH);

        // deploy executor, world and register components/systems
        let world = spawn_test_world(components, systems);

        let spawn_call_data: Array = Default::default();
        world.execute('spawn'.into(), spawn_call_data.span());

        let mut move_calldata: Array = Default::default();
        move_calldata.append(move::Direction::Right(()).into());
        world.execute('move'.into(), move_calldata.span());

        let moves = world.entity('Moves'.into(), caller.into(), 0, dojo::SerdeLen::<Moves>::len());
        assert(*moves[0] == 9, 'moves is wrong');
        let new_position = world
            .entity('Position'.into(), caller.into(), 0, dojo::SerdeLen::<Position>::len());
        assert(*new_position[0] == 1, 'position x is wrong');
        assert(*new_position[1] == 0, 'position y is wrong');
    }
}
