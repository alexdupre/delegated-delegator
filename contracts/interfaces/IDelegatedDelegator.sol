// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IDelegatedDelegator {

    event ExecutorAdded(address indexed executor);
    event ExecutorRemoved(address indexed executor);

    event DelegatorAdded(address indexed executor);
    event DelegatorRemoved(address indexed executor);

    function owner() external view returns (address);
    function wNatAddress() external view returns (address);

    function changeOwner(address newOwner) external;
    function confirmChangeOwner() external;

    function isExecutor(address executor) external view returns (bool);
    function executors() external view returns (address[] memory);
    function addExecutor(address executor) external;
    function removeExecutor(address executor) external;

    function isDelegator(address delegator) external view returns (bool);
    function delegators() external view returns (address[] memory);
    function addDelegator(address delegator) external;
    function removeDelegator(address delegator) external;

    function delegates() external view returns (address[] memory delegateAddresses, uint256[] memory bips, uint256 count);
    function delegate(address[] calldata providers, uint256[] calldata bips) external;

    function claim(address rewardManager, uint256[] calldata epochs) external; // for backward compat reasons
    function claimV1(address rewardManager, uint256 epoch) external;
    function claimV2(address rewardManager, uint24 epoch) external;
    function claimDistribution(address distributionToDelegators, uint256 month) external;

    function replaceWNat() external;

    function deposit() external payable;

    function withdraw(uint256 value, bool unwrap) external;
    function withdrawAll(bool unwrap) external;
    function withdrawAllToken(address token) external;

    function genericTransaction(address target, bytes calldata data) external payable;

}
