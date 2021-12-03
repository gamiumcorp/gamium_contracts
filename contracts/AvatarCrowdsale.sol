// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface _IERC721Contract {
    function safeMint(address to) external;
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @dev AVATAR ERC 721 Crowdsale Contract.
 *
 * 
 1. Only whitelisted addresses can mint.
 2. Max cap of the sale if determined by cap variable.
 3. Only one mint for each address that can mint.
 4. Constant price for the crowdsale.
 */
contract AvatarCrowdsale is Ownable, Pausable {
    address public ERC721Address;

    uint public salePrice; // Price of each mint in wei
    uint public cap; // Max cap of the sale
    uint public totalMinted; // Total minted from this sale

    mapping(address => bool) public _receivers;
    mapping(address => bool) private _whitelist;

    event AvatarMinted(address indexed receiver, uint _type);
    event Whitelisted(address indexed _address, bool _status);

    modifier onlyWhitelisted {
        require(_whitelist[_msgSender()], "Sender is not whitelisted");
        _;
    }

    modifier whenNotReceivedYet {
        require(!_receivers[_msgSender()], "Only can receive one Avatar per address"); // Logic is also on the Avatar.sol
        _;
    }

    constructor(address _ERC721Address, uint _salePrice, uint _cap) {
        ERC721Address = _ERC721Address;
        salePrice = _salePrice;
        cap = _cap;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /**
    * @dev Mint avatar function
    */
    function mint(uint _type) external payable whenNotPaused whenNotReceivedYet onlyWhitelisted {
        require(totalMinted + 1 <= cap, "Total cap already minted");
        require(msg.value >= salePrice, "Sent value is less than sale price");

        _IERC721Contract token = _IERC721Contract(ERC721Address);

        _receivers[_msgSender()] = true;
        totalMinted += 1;

        // Minting avatar
        token.safeMint(_msgSender());

        // Refund back the remaining to the receiver
        uint value = msg.value - salePrice;
        payable(_msgSender()).transfer(value); 
            
        emit AvatarMinted(_msgSender(), _type);
    }

    /**
    * @dev Transfer all held by the contract to the owner.
    */
    function reclaimBNB() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /**
    * @dev Transfer all ERC20 of tokenContract held by contract to the owner.
    */
    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);
    }

    /**
    * @dev Set whitelist address status true or false in bulk
    */
    function setWhitelist(address[] calldata _addresses, bool _status) external onlyOwner {
        for (uint i = 0; i < _addresses.length; i++) {
            _whitelist[_addresses[i]] = _status;
            emit Whitelisted(_addresses[i], _status);
        }
    }

    /**
    * @dev Check address whitelist status
    */
    function isWhitelist() external view returns (bool) {
        return _whitelist[_msgSender()];
    }
}
