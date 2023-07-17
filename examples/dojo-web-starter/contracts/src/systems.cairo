#[system]
mod initialize {
    use dojo::world::Context;
    use array::ArrayTrait;
    use traits::Into;
    use starknet::info::get_block_number;
    use dojo_examples::components::GameStats;
    use dojo_examples::events::{emit, GameInfo};

    // initialize game
    fn execute(ctx: Context) {
        set !(ctx.world, ctx.origin.into(), (GameStats {block_number: get_block_number(), tick_number: 0}));

        let _GameStats = get !(ctx.world, ctx.origin.into(), GameStats);

        let _block_number = _GameStats.block_number;
        let _tick_number = _GameStats.tick_number;

        // emit game created
        let mut values = array::ArrayTrait::new();
        serde::Serde::serialize(
            @GameInfo { block_number:_block_number, tick_number: _tick_number },
            ref values
        );

        emit(ctx, 'GameCreated', values.span());

        return ();
    }
}

trait IGame<T> {
    fn tick(ref self: T);
}

#[system]
mod start_game {
    use super::IGame;
    use dojo::world::Context;
    use array::ArrayTrait;
    use traits::Into;
    use dojo_examples::components::GameStats;
    use starknet::info::get_block_number;

    fn execute(ctx: Context) {
        let _GameStats = get !(ctx.world, ctx.origin.into(), GameStats);
        set !(ctx.world, ctx.origin.into(), (GameStats {block_number: get_block_number(), tick_number: _GameStats.tick_number + 1}));
        return ();
    }

    impl GameImpl of IGame<Context>{
        fn tick(ref self: Context){
            // do stuff
            return ();
        }  
    }
}

