// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/Events.sol";
import "./libraries/Errors.sol";

contract OrderBasedSwap {
    uint256 public orderCounter;

    struct Order {
        uint256 id;
        address depositor;
        IERC20 depositToken;
        uint256 depositAmount;
        IERC20 desiredToken;
        uint256 desiredAmount;
        bool isCompleted;
        bool isCanceled;
        address buyer;
        uint256 timeCreated;
        uint256 timeCanceled;
    }

    mapping(uint256 => Order) public orders;
    mapping(address => uint256[]) public depositorToOrderIds;

    
    function createOrder(
        IERC20 _depositToken,
        uint256 _depositAmount,
        IERC20 _desiredToken,
        uint256 _desiredAmount
    ) external {
        // Basic checks
        Errors.sanityCheck(msg.sender);
        Errors.sanityCheck(address(_depositToken));
        Errors.sanityCheck(address(_desiredToken));
        Errors.zeroValueCheck(_depositAmount);
        Errors.zeroValueCheck(_desiredAmount);

        // Check for sufficient balance and allowance
        if (_depositAmount > _depositToken.balanceOf(msg.sender)) {
            revert Errors.InSufficientBalance();
        }

        if (!_depositToken.transferFrom(msg.sender, address(this), _depositAmount)) {
            revert Errors.DepositFailed();
        }

        // Create new order
        uint256 orderId = ++orderCounter;
        orders[orderId] = Order({
            id: orderId,
            depositor: msg.sender,
            depositToken: _depositToken,
            depositAmount: _depositAmount,
            desiredToken: _desiredToken,
            desiredAmount: _desiredAmount,
            isCompleted: false,
            isCanceled: false,
            buyer: address(0),
            timeCreated: block.timestamp,
            timeCanceled: 0
        });

        // Track order for depositor
        depositorToOrderIds[msg.sender].push(orderId);

        // Emit order creation event
        Events.emitOrderCreated(msg.sender, address(_depositToken), _depositAmount, address(_desiredToken), _desiredAmount, block.timestamp);
    }

    function fulfillOrder(uint256 _orderId) external {
        Errors.zeroValueCheck(_orderId);
        Errors.checkIfOrderExists(orders[_orderId].id);

        Order storage order = orders[_orderId];

        // Validate order status
        if (order.isCompleted) revert Errors.OrderCompletedAlready();
        if (order.isCanceled) revert Errors.OrderCanceledAlready();

        // Check buyer balance and allowance
        if (order.desiredAmount > order.desiredToken.balanceOf(msg.sender)) {
            revert Errors.InSufficientBalance();
        }

        // Mark order as completed
        order.isCompleted = true;
        order.buyer = msg.sender;

        // Transfer desired tokens from buyer to depositor
        if (!order.desiredToken.transferFrom(msg.sender, order.depositor, order.desiredAmount)) {
            revert Errors.TransferToDepositorFailed();
        }

        // Transfer deposit tokens from contract to buyer
        if (!order.depositToken.transfer(msg.sender, order.depositAmount)) {
            revert Errors.TransferToBuyerFailed();
        }

        // Emit order completion event
        Events.emitOrderCompleted(order.id, msg.sender, address(order.depositToken), order.depositAmount, address(order.desiredToken), order.desiredAmount, block.timestamp);
    }

    function cancelOrder(uint256 _orderId) external {
        Errors.zeroValueCheck(_orderId);
        Errors.checkIfOrderExists(orders[_orderId].id);

        Order storage order = orders[_orderId];

        // Only depositor can cancel
        if (order.depositor != msg.sender) {
            revert Errors.NotOwnerOfOrder();
        }

        // Check if order is already completed or canceled
        if (order.isCompleted) revert Errors.OrderCompletedAlready();
        if (order.isCanceled) revert Errors.OrderCanceledAlready();

        // Mark order as canceled
        order.isCanceled = true;
        order.timeCanceled = block.timestamp;

        // Return deposited tokens to depositor
        if (!order.depositToken.transfer(msg.sender, order.depositAmount)) {
            revert Errors.TransferToDepositorFailed();
        }

        // Emit order cancellation event
        Events.emitOrderCanceled(order.id, msg.sender, address(order.depositToken), order.depositAmount, block.timestamp);
    }
}
