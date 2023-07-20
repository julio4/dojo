#[system]
mod start {
    use array::ArrayTrait;
    use traits::Into;
    use debug::PrintTrait;

    use dojo::world::Context;
    use dojo_ticker::components::game::{Game, GameStateKind};
    use dojo_ticker::events::{emit, GameUpdate};

    fn execute(ctx: Context) {
        let game_id = 1;

        let game = Game { id: game_id, tick: 0, state: GameStateKind::Playing(()) };
        set !(
            ctx.world, game_id.into(), (Game { id: game.id, tick: game.tick, state: game.state })
        );

        let mut values = array::ArrayTrait::new();
        serde::Serde::serialize(
            @GameUpdate { id: game.id, tick: game.tick, state: game.state.into() }, ref values
        );
        emit(ctx, 'GameUpdate', values.span());
    }
}
