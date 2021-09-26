// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;
 
import "https://github.com/sda-p/ethereum-erc721/src/contracts/tokens/nf-token-metadata.sol";
import "https://github.com/sda-p/ethereum-erc721/src/contracts/ownership/ownable.sol";
 
contract EtherGals is NFTokenMetadata, Ownable 
{
    // Properties
    address payable feeAddress;
    uint constant public galPrice = 0.00001 ether;
    uint constant public giftGals = 55;         // Gals Reserved for Giveaways and Team
    uint constant public maxGals = 5555;        // Total Gal Supply

    bool public buyingActive = false;           // Can you reserve a gal? Yes or no.
    bool public mintingActive = false;          // Is minting open? Yes or no.
    bool public isWhiteListActive = true;       // Is the public sale open or is it only whitelisted?

    mapping(address => bool) private whiteList; // Map of addresses on the whitelist.
    mapping(address => uint256) public galsReserved; // Map of how many gals are reserved for buyer addresses.
    mapping(address => uint256) private galsClaimed; // How many gals an address has claimed.
    
    mapping(address => uint256) public simps;   //Tracks simps
    mapping(uint => uint256) public simpedTo;   //Tracks total simping for each token ID

    uint256 public purchaseLimit = 5;   // Purchase limit per wallet and Max per txn
    uint256 public currentMintedGal = 0;
    uint256 public currentReservedGal = 0;
    uint256 public currentGiftGal = 0;
    uint public adjustedSimpingTax = 33; // 3.3% SIMPing tax goes to the treasury

    string private metaAddress = "https://api./";
    string constant private jsonAppend = ".json";

    // Events
    event Reserved(address sender, uint256 count);
    event Minted(address sender, uint256 count);
    event Simped(address simper, uint256 simpee, uint256 amount);
    event LimitChanged(uint256 amount);

    constructor() 
    {
        nftName = "EtherGals";
        nftSymbol = "EG";
        feeAddress = payable(msg.sender);
    }

    function tokenURI(uint tokenID) external view returns (string memory)
    {   // @dev Token URIs are generated dynamically on view requests. 
        // This is to allow easy server changes and reduce gas fees for minting. -ssa2
        require(tokenID <= currentMintedGal, "Token hasn't been minted yet.");

        bytes32 gal;
        bytes memory concat;
        gal = uintToBytes(tokenID);
        concat = abi.encodePacked(metaAddress, gal, jsonAppend);
        return string(concat);
    }

    // Toggle whether any gals can be minted at all.
    function toggleMinting() public onlyOwner
    {
        mintingActive = !mintingActive;
    }

    // Toggle whether any gals can be purchased and reserved.
    function toggleBuying() public onlyOwner
    {
        buyingActive = !buyingActive;
    }

    // Toggle if we're in the Whitelist or Public Sale.
    function toggleWhiteList() public onlyOwner
    {
        isWhiteListActive = !isWhiteListActive;
    }

    // Add a list of wallet addresses to the Whitelist.
    function addToWhiteList(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0), "Can't add the null address");

            whiteList[addresses[i]] = true;
            //galsClaimed[addresses[i]] > 0 ? galsClaimed[addresses[i]] : 0;
        }
    }

    // Tells teh world if a given address is whitelisted or not uwu.
    function onWhiteList(address addr) external view returns (bool) {
        return whiteList[addr];
    }

    // }:)
    function removeFromwhiteList(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0), "Can't add the null address");

            whiteList[addresses[i]] = false;
        }
    }

    // Tells teh world how many gals a given address has reserved to mint.
    function galsReservedBy(address owner) external view returns (uint256){
        require(owner != address(0), 'Zero address cant into reservations');

        return galsReserved[owner];
    }

    // Tells teh world how many gals a given address has bongos binted.
    function galsClaimedBy(address owner) external view returns (uint256){
        require(owner != address(0), 'Zero address cant into mintings');

        return galsClaimed[owner];
    }


    // NOTE: please remember to set this to peleus.eth send it all to me
    function updateRecipient(address payable _newAddress) public onlyOwner
    {
        feeAddress = _newAddress;
    }

    // nininininininini - Runs In Circles (does string stuff)
    function uintToBytes(uint v) private pure returns (bytes32 ret) {
        if (v == 0) 
        {
            ret = '0';
        }
        else 
        {
            while (v > 0) 
            {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }

        return ret;
    }

    function buy(uint8 _galNum) public payable
    {
        require(buyingActive, 'Reservations are not open.');
        require(_galNum > 0, 'Must reserve at least one. Cannot buy 0.');
        require(_galNum <= purchaseLimit, 'Cannot go over the current purchase limit.');
        require(currentReservedGal + giftGals + _galNum <= maxGals, 'Cannot reserve more gals than there are left to buy.');
        require(galsClaimed[msg.sender] + galsReserved[msg.sender] + _galNum <= purchaseLimit, 'Purchase exceeds max allowed per wallet.');
        require(msg.value >= galPrice * _galNum, "Insufficient ETH for the selected amount.");
        if(isWhiteListActive) 
        {
            require(whiteList[msg.sender], 'You are not on the Whitelist.');
        }

        currentReservedGal += _galNum;
        galsReserved[msg.sender] += _galNum;

        emit Reserved(msg.sender, _galNum);
    }

    // Public Sale minting function
    function mint(uint8 _galNum) public payable
    {
        require(mintingActive, 'Mintings are not yet open.');
        require(_galNum > 0, 'Must mint at least one. Cannot mint 0.');
        require(_galNum <= galsReserved[msg.sender], 'Cannot mint more Gals than you have left reserved.');
        require(currentMintedGal + _galNum <= maxGals, 'Cannot mint more gals than there are left to mint.');

        galsReserved[msg.sender] -= _galNum;

        for(uint i=0; i < _galNum; i++)
        {
            currentMintedGal += 1;
            super._mint(msg.sender, currentMintedGal);
            galsClaimed[msg.sender] += 1;
        }

        emit Minted(msg.sender, _galNum);
    }

    // Mint one of the 55 team-giveaway gals to an array of hodlers.
    function gift(address[] calldata to) external onlyOwner 
    {
        require(currentMintedGal < maxGals, "All Gals have been minted.");
        require(currentGiftGal + to.length <= giftGals, 'Not enough Gals left to gift');
        
        for(uint256 i = 0; i < to.length; i++) 
        {

            currentGiftGal += 1;
            currentMintedGal += 1;

            super._mint(to[i], currentMintedGal); // SER PLS FIX 
        }
    }

    // Mint one of the 55 team-giveaway gals. Ir's am itnrad sdlxs
    function devMint(uint8 _giftNum) external onlyOwner 
    {
        require(currentMintedGal < maxGals, "All Gals have been minted.");
        require(currentGiftGal + _giftNum <= giftGals, 'Not enough Gals left to gift');
        
        for(uint256 i = 0; i < _giftNum; i++) 
        {

            currentGiftGal += 1;
            currentMintedGal += 1;

            super._mint(msg.sender, currentMintedGal);
        }
    }

    // Father forgive me for I have SIMPED.
    function simp(uint ID) public payable
    {
        simps[msg.sender] += msg.value;
        uint256 simptax = (msg.value / 1000) * adjustedSimpingTax;
        uint256 transferam = msg.value - simptax;
        simpedTo[ID] += transferam;
        payable(NFToken.ownerOfInternal(ID)).transfer(transferam);
        feeAddress.transfer(simptax);

        emit Simped(msg.sender, ID, msg.value);
    }

    // Withdraw the ETH stored in the contract.
    function withdrawETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Update the metadata URI to a new server or IPFS if needed.
    function updateURI(string calldata _URI) external onlyOwner {
        metaAddress = _URI;
    }

    // Increase the amount of Gals that can be minted.
    function updateLimit(uint newLimit) external onlyOwner
    {
        purchaseLimit = newLimit;
        emit LimitChanged(purchaseLimit);
    }
    
     function updateSimpingTax(uint newSimpTax) external onlyOwner 
    {
        adjustedSimpingTax = newSimpTax;
    }
}
