// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract CommunityCrowdsale is Ownable {
    address public ERC20Address; //BUSD smart contract

    uint public totalCap = 75000000000000000000000; // Max total cap of the round
    uint public cap = 250000000000000000000; // Max cap of each allocation
    uint public endTimeSale = 1647576000; // When does the sale ends

    bool public unpaused;
    uint public totalCollected; // Total collected

    address public receiverAddress = 0x622b2BfB897cBE6eB49B9837d24445Af7a5B59D8; // receiver address

    mapping(address => uint) public _allocated;
    mapping(address => bool) public _whitelist;

    event ERC20Deposited(address indexed receiver, uint amount);
    event Whitelisted(address indexed _address, bool _status);

    modifier onlyWhitelisted {
        require(_whitelist[_msgSender()], "Sender is not whitelisted");
        _;
    }

    modifier whenNotPaused {
        require(unpaused, "Paused: paused sale");
        _;
    }

    constructor() {}

    function setEndTime(uint _endTime) external onlyOwner {
        endTimeSale = _endTime;
    }

    function setERC20Address(address _ERC20Address) external onlyOwner {
        ERC20Address = _ERC20Address;
    }

    function pause() external onlyOwner {
        unpaused = false;
    }

    function unpause() external onlyOwner {
        unpaused = true;
    }

    function deposit(uint amount) external whenNotPaused onlyWhitelisted {
        require(block.timestamp < endTimeSale, "Sale ended");
        require(totalCollected <= totalCap, "Max allocation surpassed... Sale ended");
        require(amount > 0, "Min amount deposit is zero");
        require(_allocated[_msgSender()] + amount <= cap, "Max allocation surpassed");

        IERC20 tokenAcceptedSale = IERC20(ERC20Address);

        _allocated[_msgSender()] += amount;
        totalCollected += amount;

        tokenAcceptedSale.transferFrom(msg.sender, address(this), amount);
        emit ERC20Deposited(_msgSender(), amount);
    }

    /**
    * @dev Transfer all held by the contract to the owner.
    */
    function reclaimBNB() external onlyOwner {
        payable(receiverAddress).transfer(address(this).balance);
    }

    /**
    * @dev Transfer all ERC20 of tokenContract held by contract to the owner.
    */
    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(receiverAddress, balance);
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