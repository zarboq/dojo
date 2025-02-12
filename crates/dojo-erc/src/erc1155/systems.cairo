#[system]
mod ERC1155SetApprovalForAll {
    use traits::Into;
    use dojo::world::Context;
    use dojo_erc::erc1155::components::OperatorApproval;

    fn execute(ctx: Context, token: felt252, owner: felt252, operator: felt252, approved: bool) {
        let mut operator_approval = get !(ctx.world, (token, owner, operator), OperatorApproval);
        operator_approval.approved = approved;
        set !(
            ctx.world,
            (operator_approval),
        )
    }
}

// TODO uri storage may not fit in a single felt
#[system]
mod ERC1155SetUri {
    use traits::Into;
    use dojo::world::Context;
    use dojo_erc::erc1155::components::Uri;

    fn execute(ctx: Context, token: felt252, uri: felt252) {
        let mut _uri = get !(ctx.world, (token), Uri);
        _uri.uri = uri;
        set !(ctx.world, (_uri))
    }
}

#[system]
mod ERC1155Update {
    use traits::Into;
    use dojo_erc::erc1155::components::Balance;
    use array::ArrayTrait;
    use dojo::world::Context;
    use zeroable::Zeroable;

    fn execute(
        ctx: Context,
        token: felt252,
        operator: felt252,
        from: felt252,
        to: felt252,
        ids: Array<felt252>,
        amounts: Array<felt252>,
        data: Array<felt252>
    ) {
        let mut index = 0;
        loop {
            if index == ids.len() {
                break();
            }
            let id = *ids.at(index);
            let amount = *amounts.at(index);

            if (from.is_non_zero()) {
                let mut from_balance = get !(ctx.world, (token, id, from), Balance);
                from_balance.amount = from_balance.amount - amount;
                let amount256: u256 = amount.into(); 
                assert(from_balance.amount.into() >= amount256, 'ERC1155: insufficient balance');
                set !(
                    ctx.world,
                    (from_balance)
                );
            }

            if (to.is_non_zero()) {
                let mut to_balance = get !(ctx.world, (token, id, to), Balance);
                to_balance.amount = to_balance.amount + amount;
                set !(
                    ctx.world,
                    (to_balance)
                );
            }
            index += 1;
        };
    }
} 