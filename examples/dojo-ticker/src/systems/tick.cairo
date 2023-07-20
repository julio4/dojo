#[system]
mod tick {
    use array::ArrayTrait;
    use traits::{Into, TryInto};
    use serde::Serde;
    use debug::PrintTrait;
    use dojo::world::Context;

    use dojo_ticker::components::game::{Game, GameStateKind};
    use dojo_ticker::events::{emit, GameUpdate};

    #[derive(Copy, Drop, Serde)]
    enum Tasks {
        all: (),
        update: (),
        spawn: (),
    }

    fn execute(ctx: Context) {
        let game_id = 1;

        let mut game: Game = get !(ctx.world, game_id.into(), Game);

        match game.state {
            GameStateKind::Playing(_) => {
                game.tick += 1;

                set !(
                    ctx.world,
                    game_id.into(),
                    (Game { id: game.id, tick: game.tick, state: game.state,  })
                )

                let mut values = array::ArrayTrait::new();
                serde::Serde::serialize(
                    @GameUpdate { id: game.id, tick: game.tick, state: game.state.into() },
                    ref values
                );
                emit(ctx, 'GameUpdate', values.span());
            },
            GameStateKind::Idle(_) => {}
        }
    }
}
