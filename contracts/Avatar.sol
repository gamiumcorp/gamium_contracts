// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./PausableAddress.sol";

/**
 * @dev AVATAR ERC 721 Contract.
 *
 * This is a standard ERC721 contract with added modifiers. 
 1. By default, AVATAR cannot be transfered by any address. Only Pauser Role can allow some accounts to transfer their AVATAR
    by calling unpause(address account) function.
 2. AVATAR can only be minted to one address once. Modifier allow us this functionality whenAddressNotMintedTo(to)
 */
contract Avatar is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, AccessControl, ERC721Burnable, PausableAddress {
    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    // Base URI
    string private _baseURIextended;

    // Address already minted, only one avatar can be minted to an address.
    mapping (address => bool) private _addressAlreadyMintedTo;

    event AvatarMinted(address indexed from, address indexed receiver);

    constructor() ERC721("Avatar", "AVT") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function setBaseURI(string memory baseURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseURIextended = baseURI_;
    }

    //
    // Pausing and unpausing functions
    //

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Pause the transfer of one address, this address will not be able to transfer tokens.
     */
    function pause(address account) public onlyRole(PAUSER_ROLE) {
        _pauseAddress(account);
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Unpause the transfer of one address, this address will be able to transfer tokens.
     */
    function unpause(address account) public onlyRole(PAUSER_ROLE) {
        _unpauseAddress(account);
    }

    //
    // Minting functions
    //

    function safeMint(address to) external onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI(tokenId));
        _addressAlreadyMintedTo[to] = true;

        emit AvatarMinted(_msgSender(), to);
    }

    //
    // Other functions
    //

    modifier whenAddressNotMintedTo(address account) {
        require(!_addressAlreadyMintedTo[account], "Minted: Address already minted to");
        _;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        whenAddressNotPaused(from)
        whenAddressNotMintedTo(to)
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}