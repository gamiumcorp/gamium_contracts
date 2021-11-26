// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenAddressNotPaused` and `whenAddressPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableAddress is Context {
        /**
     * @dev Emitted when the pause is triggered by `account` to pause 'to'
     */
    event AddressPaused(address account, address to);

    /**
     * @dev Emitted when the pause is lifted by `account` to unpause 'to'
     */
    event AddressUnpaused(address account, address to);

    // By default all addresses are unpaused, after the minting, then the address remains paused.
    mapping (address => bool) private _addressNotPaused;

    /**
     * @dev Returns true if the address is paused, and false otherwise.
     */
    function isAddressPaused(address account) public view virtual returns (bool) {
        return !_addressNotPaused[account];
    }

    /**
     * @dev Modifier to make a function callable only when the address is not paused.
     *
     * Requirements:
     *
     * - The address must not be paused.
     */
    modifier whenAddressNotPaused(address account) {
        require(_addressNotPaused[account], "Pausable: paused address");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the address is paused.
     *
     * Requirements:
     *
     * - The address must be paused.
     */
    modifier whenAddressPaused(address account) {
        require(!_addressNotPaused[account], "Pausable: not paused address");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The address must not be paused.
     */
    function _pauseAddress(address account) internal virtual whenAddressNotPaused(account) {
        _addressNotPaused[account] = false;
        emit AddressPaused(_msgSender(), account);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The address must be paused.
     */
    function _unpauseAddress(address account) internal virtual whenAddressPaused(account) {
        _addressNotPaused[account] = true;
        emit AddressUnpaused(_msgSender(), account);
    }
}
