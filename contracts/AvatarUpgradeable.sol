// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "./PausableAddressUpgradeable.sol";

/**
 * @dev AVATAR ERC 721 Contract.
 *
 * This is a standard ERC721 contract with added modifiers. 
 1. By default, AVATAR cannot be transfered by any address. Only Pauser Role can allow some accounts to transfer their AVATAR
    by calling unpause(address account) function.
 2. AVATAR can only be minted to one address once. Modifier allow us this functionality whenAddressNotMintedTo(to)
 */
contract AvatarUpgradeable is Initializable, ERC721Upgradeable, ERC721EnumerableUpgradeable, ERC721URIStorageUpgradeable, PausableUpgradeable, AccessControlUpgradeable, ERC721BurnableUpgradeable, PausableAddressUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    CountersUpgradeable.Counter private _tokenIdCounter;

    // Base URI
    string private _baseURIextended;

    // Address already minted, only one avatar can be minted to an address.
    mapping (address => bool) private _addressAlreadyMintedTo;
    // Some address can receive unlimited mintings.
    mapping (address => bool) private _addressUnlimitedMintedTo;

    event AvatarMinted(address indexed from, address indexed receiver);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() initializer public {
        __ERC721_init("Avatar", "AVT");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __Pausable_init();
        __PausableAddress_init();
        __AccessControl_init();
        __ERC721Burnable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function setBaseURI(string memory baseURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseURIextended = baseURI_;
    }

    function setUnlimitedMintingTo(address account, bool status) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _addressUnlimitedMintedTo[account] = status;
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

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenURI(tokenId));
        _addressAlreadyMintedTo[to] = true;

        emit AvatarMinted(_msgSender(), to);
    }

    modifier whenAddressNotMintedTo(address account) {
        require(!_addressAlreadyMintedTo[account] || _addressUnlimitedMintedTo[account], "Minted: Address already received max minting");
        _;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        whenAddressNotPaused(from)
        whenAddressNotMintedTo(to)
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
