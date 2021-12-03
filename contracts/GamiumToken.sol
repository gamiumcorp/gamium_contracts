// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";


contract GamiumToken is ERC20Capped, Ownable {
    // minter address
    address public minter;

    // events
    event TokensMinted(address _to, uint256 _amount);
    event LogNewMinter(address _minter);

    // max total Supply to be minted
    uint256 private _capToken = 50 * 10 ** 9 * 1e18;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) ERC20Capped(_capToken) {
    }
    
    /**
     * @dev Throws if called by any account other than the minter.
     */
    modifier onlyMinter() {
        require(_msgSender() != address(0), "ERC20: minting from the zero address");
        require(_msgSender() == minter, "Caller is not the minter");
        _;
    }
    
    /**
     * @param newMinter The address of the new minter.
     */
    function setMinter(address newMinter) external onlyOwner {
        require(newMinter != address(0), "ERC20: Cannot set zero address as minter.");
        minter = newMinter;
        emit LogNewMinter(minter);
    }
    
    /**
     * @dev minting function.
     *
     * Emits a {TokensMinted} event.
     */
    function mint(address account, uint256 amount) external onlyMinter {
        super._mint(account, amount);
        emit TokensMinted(account, amount);
    }
}