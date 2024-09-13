const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("DelegatedDelegatorFactory", (m) => {
  const factory = m.contract("DelegatedDelegatorFactory");

  return { factory };
});