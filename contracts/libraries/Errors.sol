// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Errors {
    error ZeroAddressNotAllowed();
    error ZeroValueNotAllowed();
    error InSufficientBalance();
    error DepositFailed();
    error TransferToDepositorFailed();
    error TransferToBuyerFailed();
    error OrderCompletedAlready();
    error OrderCanceledAlready();
    error InvalidOrder();
    error NotOwnerOfOrder();

    function sanityCheck(address _address) external pure {
        if (_address == address(0)) {
            revert ZeroAddressNotAllowed();
        }
    }

    function zeroValueCheck(uint256 _value) external pure {
        if (_value == 0) {
            revert ZeroValueNotAllowed();
        }
    }

    function checkIfOrderExists(uint256 _id) external pure {
        if (_id == 0) {
            revert InvalidOrder();
        }
    }
}
