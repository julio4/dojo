#[cfg(test)]
mod ticker_tests {
    // use super::EmptyTarget;
    use ticker::ticker::{
        ITarget, ITargetDispatcher, ITargetDispatcherTrait,
        ITicker, ITickerDispatcher, ITickerDispatcherTrait,
        Ticker
    };
    use debug::PrintTrait;
    use starknet::{deploy_syscall, ContractAddress, get_caller_address};
    use option::OptionTrait;
    use array::ArrayTrait;
    use traits::{Into, TryInto};
    use starknet::class_hash::Felt252TryIntoClassHash;
    use result::ResultTrait;

    #[starknet::contract]
    mod EmptyTarget {
        #[storage]
        struct Storage {}

        #[external(v0)]
        impl EmptyTarget of ticker::ticker::ITarget<ContractState> {
            fn tick(self: @ContractState) {}
        }
    }

    fn deploy_target() -> ContractAddress {
        let (contract_address, _) = deploy_syscall(
            EmptyTarget::TEST_CLASS_HASH.try_into().unwrap(),
            0,
            ArrayTrait::new().span(),
            false
        )
            .unwrap();
        contract_address
    }

    fn deploy_ticker(depositor: ContractAddress) -> ITickerDispatcher {
        let target = deploy_target();
        let mut calldata: Array<felt252> = ArrayTrait::new();
        calldata.append(depositor.into());
        calldata.append(target.into());
        let (contract_address, _) = deploy_syscall(
            Ticker::TEST_CLASS_HASH.try_into().unwrap(),
            0,
            calldata.span(),
            false
        )
            .unwrap();
        ITickerDispatcher { contract_address }
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_deploy() {
        deploy_ticker(get_caller_address());
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_tick() {
        let ticker = deploy_ticker(get_caller_address());
        ticker.apply_tick();
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_set_target() {
        let ticker = deploy_ticker(get_caller_address());
        let new_target = deploy_target();
        ticker.set_target(new_target);
    }
}
