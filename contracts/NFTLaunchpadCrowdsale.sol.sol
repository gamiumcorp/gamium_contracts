// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";


contract GallerCrowdsale is Pausable, Ownable {

    // Address of ERC721 token contract.
    IERC721 public NFTCrowdsale;
    address public NFTAddress; 

    using Strings for uint256;

    string public baseURI;
    string public suffix;

    uint256 public LAUNCH_MAX_SUPPLY; // max launch supply
    uint256 public LAUNCH_SUPPLY; // current launch supply

    address public LAUNCHPAD; // launchpad address

    uint256 public tokenIDstart; // tokenID which is minted first, then tokenIDstart to LAUNCH_MAX_SUPPLY -1 can be minted

    modifier onlyLaunchpad() {
        require(LAUNCHPAD != address(0), "launchpad address must set");
        require(msg.sender == LAUNCHPAD, "must call by launchpad");
        _;
    }

    function getMaxLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_MAX_SUPPLY;
    }

    function getLaunchpadSupply() view public returns (uint256) {
        return LAUNCH_SUPPLY;
    }

    constructor(string memory baseURI_, string memory suffix_, address launchpad, uint256 maxSupply, address nftAddress_, uint256 tokenIDStart_) {
        baseURI = baseURI_;
        suffix = suffix_;
        LAUNCHPAD = launchpad;
        LAUNCH_MAX_SUPPLY = maxSupply;

        NFTAddress = nftAddress_;
        tokenIDstart = tokenIDStart_;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _baseURI() internal view virtual returns (string memory){
        return baseURI;
    }

    function setBaseURI(string memory _newURI) external onlyOwner {
        baseURI = _newURI;
    }

    function setSuffix(string memory suffix_) external onlyOwner {
        suffix = suffix_;
    }

    function setLaunchpad(address launchpad_) external onlyOwner {
        LAUNCHPAD = launchpad_;
    }

    function setTokenIDStart(uint256 tokenIDStart_) external onlyOwner {
        tokenIDstart = tokenIDStart_;
    }

    function setNFTAddress(address nftAddress_) external onlyOwner {
        NFTAddress = nftAddress_;
    }

    function tokenURI(uint256 tokenId) public view virtual returns (string memory) {
        require(tokenId < tokenIDstart + LAUNCH_SUPPLY, "ERC721Metadata: URI query for nonexistent token.");
        return string(abi.encodePacked(baseURI, tokenId.toString(), suffix));
    }

    // @dev Function to be able to receive and send NFTs from the smart contract
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        public
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }

    // you must impl this in your NFT contract
    // you NFT contract is responsible to maintain the tokenId
    // you may have another mint function hold by yourself, to skip the process after presale end
    // max size will be 10
    function mintTo(address to, uint size) external onlyLaunchpad {
        require(to != address(0), "can't mint to empty address");
        require(size > 0, "size must greater than zero");
        require(LAUNCH_SUPPLY + size <= LAUNCH_MAX_SUPPLY, "max supply reached");

        IERC721 token = IERC721(NFTAddress);

        for (uint256 i=1; i <= size; i++) {
            uint256 tokenID = tokenIDstart + LAUNCH_SUPPLY;
            token.safeTransferFrom(address(this), to, tokenID);
            LAUNCH_SUPPLY++;
        }
    }
}