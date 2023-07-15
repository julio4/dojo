#[starknet::interface]
trait ITarget<TContractState> {
    fn tick(self: @TContractState);
}

#[starknet::interface]
trait ITicker<TContractState> {
    fn apply_tick(self: @TContractState);
}

#[starknet::contract]
mod Ticker {
    use super::{ITargetDispatcher, ITargetDispatcherTrait};
    use starknet::{ContractAddress};

    #[storage]
    struct Storage {
        depositor: ContractAddress,
        target: ITargetDispatcher,
    }

    #[constructor]
    fn constructor(ref self: ContractState, depositor: ContractAddress, target: ContractAddress) {
        self.depositor.write(depositor);
        self.target.write(ITargetDispatcher { contract_address: target });
    }

    #[external(v0)]
    impl Ticker of super::ITicker<ContractState> {
        fn apply_tick(self: @ContractState) {
            self.target.read().tick();
        }
    }
}
