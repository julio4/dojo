use array::ArrayTrait;
use dojo::SerdeLen;
use debug::PrintTrait;
use traits::{Into, PartialEq};

#[derive(PartialEq, Copy, Drop, Serde)]
enum GameStateKind {
    Playing: (),
    Idle: (),
}

impl GameStateKindSerdeLen of SerdeLen<GameStateKind> {
    #[inline(always)]
    fn len() -> usize {
        1
    }
}

impl GameStateIntoFelt252 of Into<GameStateKind, felt252> {
    fn into(self: GameStateKind) -> felt252 {
        match self {
            GameStateKind::Playing(_) => {
                'Playing'.into()
            },
            GameStateKind::Idle(_) => {
                'Idle'.into()
            },
        }
    }
}

impl GameStatePrintTrait of PrintTrait<GameStateKind> {
    #[inline(always)]
    fn print(self: GameStateKind) {
        let str: felt252 = self.into();
        str.print();
    }
}

#[derive(Component, PartialEq, Copy, Drop, Serde, SerdeLen)]
struct Game {
    id: u32,
    tick: u32,
    state: GameStateKind,
}

impl GamePrintTrait of PrintTrait<Game> {
    #[inline(always)]
    fn print(self: Game) {
        'Game: '.print();
        'id: '.print();
        self.id.print();
        'tick: '.print();
        self.tick.print();
        'state: '.print();
        self.state.print();
    }
}
