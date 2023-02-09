// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import './interfaces/IDelegatedDelegator.sol';

import './FlareLibrary.sol';

contract DelegatedDelegator is IDelegatedDelegator {

    address public owner;
    address private pendingOwner;
    mapping(address => uint256) private executorsMap;
    address[] private executorsArray;
    mapping(address => uint256) private delegatorsMap;
    address[] private delegatorsArray;

    IWNat public wNat = FlareLibrary.getWNat();

    modifier onlyOwner {
        require(msg.sender == owner, 'Forbidden');
        _;
    }

    modifier onlyOwnerOrExecutors {
        require(msg.sender == owner || executorsMap[msg.sender] > 0, 'Forbidden');
        _;
    }

    modifier onlyOwnerOrDelegators {
        require(msg.sender == owner || delegatorsMap[msg.sender] > 0, 'Forbidden');
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

    function isExecutor(address executor) external view returns (bool) {
        return executorsMap[executor] > 0;
    }

    function executors() external view returns (address[] memory) {
        return executorsArray;
    }

    function addExecutor(address executor) external onlyOwner {
        if (executorsMap[msg.sender] == 0) {
            executorsArray.push(executor);
            executorsMap[executor] = executorsArray.length;
            emit ExecutorAdded(executor);
        }
    }

    function removeExecutor(address executor) external onlyOwner {
        uint256 i = executorsMap[msg.sender];
        if (i > 0) {
            if (i < executorsArray.length) {
                address lastExecutor = executorsArray[executorsArray.length - 1];
                executorsArray[i - 1] = lastExecutor;
                executorsMap[lastExecutor] = i;

            }
            executorsArray.pop();
            executorsMap[executor] = 0;
            emit ExecutorRemoved(executor);
        }
    }

    function isDelegator(address delegator) external view returns (bool) {
        return delegatorsMap[delegator] > 0;
    }

    function delegators() external view returns (address[] memory) {
        return delegatorsArray;
    }

    function addDelegator(address delegator) external onlyOwner {
        if (delegatorsMap[msg.sender] == 0) {
            delegatorsArray.push(delegator);
            delegatorsMap[delegator] = delegatorsArray.length;
            emit DelegatorAdded(delegator);
        }
    }

    function removeDelegator(address delegator) external onlyOwner {
        uint256 i = delegatorsMap[msg.sender];
        if (i > 0) {
            if (i < delegatorsArray.length) {
                address lastDelegator = delegatorsArray[delegatorsArray.length - 1];
                delegatorsArray[i - 1] = lastDelegator;
                delegatorsMap[lastDelegator] = i;

            }
            delegatorsArray.pop();
            delegatorsMap[delegator] = 0;
            emit DelegatorRemoved(delegator);
        }
    }

    function delegates() external view returns (address[] memory delegateAddresses, uint256[] memory bips, uint256 count) {
        (delegateAddresses, bips, count, ) = wNat.delegatesOf(address(this));
    }

    function delegate(address[] calldata providers, uint256[] calldata bips) external onlyOwnerOrDelegators {
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