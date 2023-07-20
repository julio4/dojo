#[system]
mod init {
    use array::ArrayTrait;
    use traits::Into;

    use dojo::world::Context;
    use dojo_ticker::components::game::{Game, GameStateKind};
    use dojo_ticker::events::{emit, GameCreated};

    fn execute(ctx: Context) {
        let game_id = ctx.world.uuid();
        let game_sk: Query = game_id.into();

        let game = Game { id: game_id, tick: 0, state: GameStateKind::Idle(()),  };
        set !(ctx.world, game_sk, (game));

        let mut values = array::ArrayTrait::new();
        serde::Serde::serialize(
            @GameCreated { id: game.id, tick: game.tick, state: game.state.into() }, ref values
        );
        emit(ctx, 'GameCreated', values.span());

        return ();
    }
}
