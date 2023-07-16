use starknet::ContractAddress;

#[starknet::interface]
trait ITarget<TContractState> {
    fn tick(self: @TContractState);
}

#[starknet::interface]
trait ITicker<TContractState> {
    fn apply_tick(self: @TContractState);
    fn set_target(ref self: TContractState, target: ContractAddress);
}

#[starknet::contract]
mod Ticker {
    use super::{ITargetDispatcher, ITargetDispatcherTrait};
    use starknet::{ContractAddress, get_caller_address};

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
            assert(get_caller_address() == self.depositor.read(), 'Not depositor');
            self.target.read().tick();
        }

        fn set_target(ref self: ContractState, target: ContractAddress) {
            assert(get_caller_address() == self.depositor.read(), 'Not depositor');
            self.target.write(ITargetDispatcher { contract_address: target });
        }
    }
}
