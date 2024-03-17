# Harberger Toolkit

This repository aims to develop a suite of configurable smart contracts that allow developers to easily deploy tokens utilizing the Harberger Tax.

## Use Case Examples

### Sustainable Community

This is a method for expanding a community treasury while also imposing a fee for community access. Create a series of 10,000 Harberger PFPs (Profile Picture NFTs). Holders of these PFPs gain access to the community Discord, Telegram, etc. The PFPs can have different rarities, enabling various members to assign value and status to them. The taxes collected contribute to a community treasury for launching various initiatives.

### App Subscription

Implement a self-regulating app subscription model with Harberger tokens. If you own an app or a beta version with a restricted number of available slots, you can issue Harberger tokens and allow token holders to authenticate and access your app. As the app's value increases and demand for usage rises, the token's value will also rise accordingly.

### Royalties

Creators can introduce art tokens with enforceable royalties. Since the contract can always be invoked to obtain a token, other contracts cannot easily wrap the tokens to circumvent paying royalties. This is because the token represented by a derivative could be reclaimed at any time by the Harberger contract.

## Configurable

We wanted the initial implementation to be compatible with many different use cases. That is why there are plenty of variables that you can specify and update as the collection admin.

**On initialization**:

Besides the usual ERC721 initialization config you can set:

`taxPeriod`: The period over which tax will be charged. One year is a good default parameter.

`minPeriodCovered`: This is the minimum period that someone will have to deposit when acquiring a token. If you have a yearly tax period with a 10% tax and a minPeriodCovered of 6 months, then they will have to deposit 5% of whatever they value a token in order to get it. Tax will be charged from this.

`previousHolderShare`: Gives a share of the new valuation to the previous holder as a purchasing fee. The higher this is set, the more speculation you will have in your collection.

`benefactorShare`: This is similar to a royalty but there is no way to wrap the collection to avoid it. It is charged any time someone acquires a token. It can be set to zero.

**Admin configs**:
`setMinPeriodCovered`: Lets the admin update the minimum period of taxes that has to be deposited when acquiring a new token.
`setTaxNumerator`: Lets the admin update the rate at which to charge taxes. A value of 10000 equals 100% taxes for each taxPeriod.
`setBenefactorShare`: Specifies how much of the valuation specified by the new holder will go to the benefactor as a purchasing fee. It can be anything from 0 to 10000 which equals 100%.
`setPreviousHolderShare`: Specifies how much of the valuation specified by the new holder will go to the previous holder as a purchasing fee. It can be anything from 0 to 10000 which equals 100%.

## Speculation

This Harberger implementation is compatible and configurable for varying levels of speculation. You can set all acquisition fees to 0, eliminating the incentive to speculate on a token's value increasing. Alternatively, you can adjust both the holding tax fee with `setTaxNumerator` and the purchase tax fee with `setBenefactorShare` and `setPreviousHolderShare` to either increase or decrease speculation in your collection.

## Upcoming Updates

1.  ERC20 Compatibility: The current contract is tailored to interact with the native token of a blockchain. Support for ERC20 tokens will be added for enhanced compatibility.
2.  Foreclosure Incentives: Optional incentives will be introduced for blockchain agents to foreclose defaulted tokens, incentivizing adherence to token obligations.
3.  Additional Token Acquisition Modules: Currently, tokens are acquired through direct purchase. An auction acquisition model will be integrated to provide users with more acquisition options.

## Previous Implementations

Wildcards: https://github.com/wildcards-world/harberger-base-contracts

Geo web: [https://docs.geoweb.network/](https://docs.geoweb.network/)

Radical pixels: [https://github.com/RadicalPixels](https://github.com/RadicalPixels)

Orbland: [https://orb.land/](https://orb.land/)

Radical domains: [https://github.com/rkalis/radical.domains](https://github.com/rkalis/radical.domains)

This artwork is always on sale: [https://thisartworkisalwaysonsale.com/](https://thisartworkisalwaysonsale.com/)

## Useful Bibliography

Governing the commons, Elinor Ostrom [https://www.cambridge.org/core/books/governing-the-commons/A8BB63BC4A1433A50A3FB92EDBBB97D5](https://www.cambridge.org/core/books/governing-the-commons/A8BB63BC4A1433A50A3FB92EDBBB97D5)

Vitalik buterin on Harberger tax

[https://ethresear.ch/t/highlight-robin-hansons-more-owner-forgiving-modified-harberger-tax/5720](https://ethresear.ch/t/highlight-robin-hansons-more-owner-forgiving-modified-harberger-tax/5720)

[https://old.reddit.com/r/ethereum/comments/mo9mw8/reminder_in_the_long_run_asset_transfer_fees_are/](https://old.reddit.com/r/ethereum/comments/mo9mw8/reminder_in_the_long_run_asset_transfer_fees_are/)

Radical markets, Chapter 1, by Eric Posner and Glen Weyl

Podcast “Economic design” by Lisa JY Tan, chapter 46 “EP46-Depreciating-Licensing-Model-in-NFT-Ownership-with-Anthony-Lee-Zhang”

[https://podcasters.spotify.com/pod/show/economicsdesign/episodes/EP46-Depreciating-Licensing-Model-in-NFT-Ownership-with-Anthony-Lee-Zhang-from-UChicago-Booth-eu5q86](https://podcasters.spotify.com/pod/show/economicsdesign/episodes/EP46-Depreciating-Licensing-Model-in-NFT-Ownership-with-Anthony-Lee-Zhang-from-UChicago-Booth-eu5q86)

Simon de la rouviere, What is Harberger Tax & Where Does The Blockchain Fit In?

[https://medium.com/@simondlr/what-is-harberger-tax-where-does-the-blockchain-fit-in-1329046922c6](https://medium.com/@simondlr/what-is-harberger-tax-where-does-the-blockchain-fit-in-1329046922c6)
