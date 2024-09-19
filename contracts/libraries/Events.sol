// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Events {
    event OrderCreated(
        address indexed depositor,
        address depositToken,
        uint256 depositAmount,
        address desiredToken,
        uint256 desiredAmount,
        uint256 timeCreated
    );

    event OrderCompleted(
        uint256 indexed orderId,
        address indexed buyer,
        address depositToken,
        uint256 depositAmount,
        address desiredToken,
        uint256 desiredAmount,
        uint256 timeCompleted
    );

    event OrderCanceled(
        uint256 indexed orderId,
        address indexed depositor,
        address depositToken,
        uint256 depositAmount,
        uint256 timeCanceled
    );

    function emitOrderCreated(
        address _depositor,
        address _depositToken,
        uint256 _depositAmount,
        address _desiredToken,
        uint256 _desiredAmount,
        uint256 _timeCreated
    ) external {
        emit OrderCreated(_depositor, _depositToken, _depositAmount, _desiredToken, _desiredAmount, _timeCreated);
    }

    function emitOrderCompleted(
        uint256 _orderId,
        address _buyer,
        address _depositToken,
        uint256 _depositAmount,
        address _desiredToken,
        uint256 _desiredAmount,
        uint256 _timeCompleted
    ) external {
        emit OrderCompleted(_orderId, _buyer, _depositToken, _depositAmount, _desiredToken, _desiredAmount, _timeCompleted);
    }

    function emitOrderCanceled(
        uint256 _orderId,
        address _depositor,
        address _depositToken,
        uint256 _depositAmount,
        uint256 _timeCanceled
    ) external {
        emit OrderCanceled(_orderId, _depositor, _depositToken, _depositAmount, _timeCanceled);
    }
}
