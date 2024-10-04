// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition


import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SwaptokenModule = buildModule("SwaptokenModule", (m) => {

  const OrderBasedSwap = m.contract("OrderBasedSwap");


  return { OrderBasedSwap };
});

export default SwaptokenModule;



