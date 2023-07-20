#[system]
mod init {
    use array::ArrayTrait;
    use traits::Into;
    use debug::PrintTrait;

    use dojo::world::Context;
    use dojo_ticker::components::game::{Game, GameStateKind};
    use dojo_ticker::events::{emit, GameCreated};

    fn execute(ctx: Context) -> u32 {
        let game_id = 1;

        let game = Game { id: game_id, tick: 0, state: GameStateKind::Idle(()) };
        set !(
            ctx.world, game_id.into(), (Game { id: game.id, tick: game.tick, state: game.state })
        );

        let mut values = array::ArrayTrait::new();
        serde::Serde::serialize(
            @GameCreated { id: game.id, tick: game.tick, state: game.state.into() }, ref values
        );
        emit(ctx, 'GameCreated', values.span());

        game_id
    }
}
