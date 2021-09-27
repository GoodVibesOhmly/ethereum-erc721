# ERC-721 Token — Modified Standard

This is a modified version of the reference ERC-721 implementation.

The purpose of this fork is to enable procedural metadata generation, an optimal reservation system, and gas-efficient minting.

## Structure

The structure of this repository follows 0xcert's main branch. The main areas of note are:

- [`ethergals.sol`](src/contracts/tokens/ethergals.sol): The actual contract implementation.
- [`nf-token.sol`](src/contracts/tokens/nf-token.sol): The previous static token URI definition has been removed, and an internal ownerOf() function analogue has been added to support contract logic.
- [`nf-token-metadata.sol`](src/contracts/tokens/nf-token-metadata.sol): The static metadata implementation found here has been removed, leaving only base contract information such as the name and symbol.

Other files in the [tokens](src/contracts/tokens) and [utils](src/contracts/utils) directories named `erc*.sol` are interfaces and define the respective standards.

Mock contracts showing basic contract usage are available in the [mocks](src/contracts/mocks) folder.

There are also test mocks that can be seen [here](src/tests/mocks). These are specifically made to test different edge cases and behaviours and should NOT be used as a reference for implementation.
