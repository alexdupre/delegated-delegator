// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

import './IFlare.sol';

interface IDelegatedDelegator {

    event ExecutorAdded(address indexed executor);
    event ExecutorRemoved(address indexed executor);

    function owner() external view returns (address);
    function executors(address) external view returns (bool);
    function wNat() external view returns (IWNat);

    function changeOwner(address newOwner) external;
    function confirmChangeOwner() external;

    function addExecutor(address executor) external;
    function removeExecutor(address executor) external;

    function delegates() external view returns (address[] memory delegateAddresses, uint256[] memory bips, uint256 count);
    function delegate(address[] calldata providers, uint256[] calldata bips) external;

    function claim(IFtsoRewardManager rewardManager, uint256[] calldata epochs) external;
    function claimDistribution(IDistributionToDelegators distributionToDelegators, uint256 month) external;

    function replaceWNat() external;

    function deposit() external payable;

    function withdraw(uint256 value, bool unwrap) external;
    function withdrawAll(bool unwrap) external;
    function withdrawAllToken(IERC20 token) external;

    function genericTransaction(address target, bytes calldata data) external payable;

}
