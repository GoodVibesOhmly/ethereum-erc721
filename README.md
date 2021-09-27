# ERC-721 Token — Modified Standard
This is a modified version of the reference ERC-721 implementation.

The purpose of this fork is to enable procedural metadata generation, an optimal reservation system, and gas-efficient minting.

The structure of this repository follows 0xcert's main branch. The main areas of note are:
- [`ethergals.sol`](src/contracts/tokens/ethergals.sol): The actual contract implementation.
- [`nf-token.sol`](src/contracts/tokens/nf-token.sol): The previous static token URI definition has been removed, and an internal ownerOf() function analogue has been added to support contract logic.
- [`nf-token-metadata.sol`](src/contracts/tokens/nf-token-metadata.sol): The static metadata implementation found here has been removed, leaving only base contract information such as the name and symbol.
