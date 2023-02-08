// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import './interfaces/IDelegatedDelegator.sol';

import './FlareLibrary.sol';

contract DelegatedDelegator is IDelegatedDelegator {

    address public owner;
    address private pendingOwner;
    mapping(address => bool) public executors;

    IWNat public wNat = FlareLibrary.getWNat();

    modifier onlyOwner {
        require(msg.sender == owner, 'Forbidden');
        _;
    }

    modifier onlyOwnerOrExecutors {
        require(msg.sender == owner || executors[msg.sender], 'Forbidden');
        _;
    }

    constructor(address _owner) {
        owner = _owner;
        wNat.governanceVotePower().delegate(_owner);
    }

    receive() external payable {}

    function changeOwner(address newOwner) external onlyOwner {
        pendingOwner = newOwner;
    }

    function confirmChangeOwner() external {
        require(pendingOwner != address(0) && msg.sender == pendingOwner, 'Forbidden');
        owner = pendingOwner;
        wNat.governanceVotePower().delegate(owner);
        pendingOwner = address(0);
    }

    function addExecutor(address executor) external onlyOwner {
        if (!executors[executor]) {
            executors[executor] = true;
            emit ExecutorAdded(executor);
        }
    }

    function removeExecutor(address executor) external onlyOwner {
        if (executors[executor]) {
            executors[executor] = false;
            emit ExecutorRemoved(executor);
        }
    }

    function delegates() external view returns (address[] memory delegateAddresses, uint256[] memory bips, uint256 count) {
        (delegateAddresses, bips, count, ) = wNat.delegatesOf(address(this));
    }

    function delegate(address[] calldata providers, uint256[] calldata bips) external onlyOwnerOrExecutors {
        require(providers.length == bips.length, 'Length mismatch');
        wNat.undelegateAll();
        uint256 total;
        for (uint256 i; i < providers.length; i++) {
            wNat.delegate(providers[i], bips[i]);
            total += bips[i];
        }
        (, , uint256 count, ) = wNat.delegatesOf(address(this));
        require(total == 100_00 && count == providers.length, 'Not delegating 100%');
    }

    function claim(IFtsoRewardManager rewardManager, uint256[] calldata epochs) external onlyOwnerOrExecutors {
        rewardManager.claimReward(payable(address(this)), epochs);
        if (address(this).balance > 0) {
            wNat.deposit{value: address(this).balance }();
        }
    }

    function claimDistribution(IDistributionToDelegators distributionToDelegators, uint256 month) external onlyOwnerOrExecutors {
        distributionToDelegators.claim(address(this), address(this), month, false);
        if (address(this).balance > 0) {
            wNat.deposit{value: address(this).balance }();
        }
    }

    function replaceWNat() external onlyOwnerOrExecutors {
        IWNat newWNat = FlareLibrary.getWNat();
        if (address(newWNat) != address(wNat)) {
            wNat.withdraw(wNat.balanceOf(address(this)));
            newWNat.deposit{value: address(this).balance}();
            wNat = newWNat;
            wNat.governanceVotePower().delegate(owner);
        }
    }

    function deposit() external payable {
        wNat.deposit{value: msg.value}();
    }

    function withdraw(uint256 value, bool unwrap) public onlyOwner {
        if (unwrap) {
            if (value > 0) {
                wNat.withdraw(value);
            }
            if (address(this).balance > 0) {
                (bool success, ) = owner.call{value: address(this).balance}(new bytes(0));
                require(success, 'Transfer Error');
            }
        } else {
            wNat.transfer(owner, value);
        }
    }

    function withdrawAll(bool unwrap) external onlyOwner {
        withdraw(wNat.balanceOf(address(this)), unwrap);
    }

    function withdrawAllToken(IERC20 token) external onlyOwner {
        token.transfer(owner, token.balanceOf(address(this)));
    }

    function genericTransaction(address target, bytes calldata data) external payable onlyOwner {
        (bool success, bytes memory result) = target.call{value: msg.value}(data);
        if (!success) {
            if (result.length == 0) revert('Revert with no reason');
            assembly {
                let result_len := mload(result)
                revert(add(32, result), result_len)
            }
        }
    }

}