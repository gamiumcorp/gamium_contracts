// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20BaseContract {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract LockERC20 is Ownable {

    address tokenContract;
    uint amount;
    uint releaseTime;

    constructor() {}

    function lock(address _tokenContract, uint _amount, uint _releaseTime) external onlyOwner {
        require(_tokenContract != address(0), "Invalid address");
        require(block.timestamp > releaseTime, "Not unlocked yet");

        IERC20BaseContract tokenAcceptedSale = IERC20BaseContract(_tokenContract);
        amount = _amount;
        releaseTime = _releaseTime;
        
        tokenAcceptedSale.transferFrom(msg.sender, address(this), _amount);
    }

    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid address");
        require(block.timestamp > releaseTime, "Not unlocked yet");

        IERC20BaseContract token = IERC20BaseContract(_tokenContract);

        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner(), balance);
    }
}