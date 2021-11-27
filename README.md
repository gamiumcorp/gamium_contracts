Smart contracts related to the Gamium (GMM) token and the Avatar NFT.

**Gamium (GMM)**
- ERC20 token with capped supply, 50,000,000,000 GMM
- Minter role responsible of minting all the supply.
- Minter role assigned to GamiumAllocator contract
- GamiumAllocator is responsible for minting the tokens following GMM tokenomics (TGE+Linear for each category). 
https://gamium.world/pdf/tokenomics.pdf

**Avatar NFT**
- Upgradeable contract, deployed with @openzeppelin/truffle-upgrades.
- Avatar cannot be transfered by default, only if unpause(address) is called by Pauser Role.
- Only one avatar can be minted to an address, only if setUnlimitedMintingTo(address, true) is set, then 'address' can receive more than one Avatar.
- unpause(address(0)) to be able to mint.
- Only minter role, can call safeMint.
- Grant AvatarCrowdsale minter role. 
- AvatarCrowdsale has a fixed price for minting.
- Whitelist addresses can mint Avatar.
- AvatarCrowdsale has a cap on how many avatars can be minted.
