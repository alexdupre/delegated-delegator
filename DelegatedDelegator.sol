// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract DelegatedDelegator {

    address public owner;
    address private pendingOwner;
    mapping(address => bool) public executors;

    IWNat public immutable wNat = FlareLibrary.getWNat();

    modifier onlyOwner {
        require(msg.sender == owner, 'Forbidden');
        _;
    }

    modifier onlyOwnerOrExecutors {
        require(msg.sender == owner || executors[msg.sender], 'Forbidden');
        _;
    }

    constructor() {
        owner = msg.sender;
        wNat.governanceVotePower().delegate(owner);
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
        executors[executor] = true;
    }

    function removeExecutor(address executor) external onlyOwner {
        executors[executor] = false;
    }
    function delegate(address[] calldata providers, uint256[] calldata bips) external onlyOwnerOrExecutors {
        require(providers.length == bips.length, 'Length mismatch');
        wNat.undelegateAll();
        for (uint256 i; i < providers.length; i++) {
            wNat.delegate(providers[i], bips[i]);
        }
    }

    function claim(IFtsoRewardManager rewardManager, uint256[] calldata epochs) public onlyOwnerOrExecutors {
        rewardManager.claimReward(payable(address(this)), epochs);
        if (address(this).balance > 0) {
            wNat.deposit{value: address(this).balance }();
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
            if (result.length == 0) revert('revert with no reason');
            assembly {
                let result_len := mload(result)
                revert(add(32, result), result_len)
            }
        }
    }

}

library FlareLibrary {
    IPriceSubmitter private constant priceSubmitter = IPriceSubmitter(0x1000000000000000000000000000000000000003);

    function getFtsoManager() internal view returns (IFtsoManager) {
        return IFtsoManager(priceSubmitter.getFtsoManager());
    }

    function getFtsoRewardManager() internal view returns (IFtsoRewardManager) {
        return IFtsoRewardManager(getFtsoManager().rewardManager());
    }

    function getWNat() internal view returns (IWNat) {
        return IWNat(getFtsoRewardManager().wNat());
    }
}

interface IPriceSubmitter {
    function getFtsoManager() external view returns (address);
}

interface IFtsoManager {
    function rewardManager() external view returns (address);
}

interface IFtsoRewardManager {
    function wNat() external view returns (address);

    function claimReward(
        address payable _recipient,
        uint256[] calldata _rewardEpochs
    ) external returns (uint256 _rewardAmount);
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
}

interface IGovernanceVotePower {
    function delegate(address _to) external;
}


interface IVPToken {
    function delegate(address _to, uint256 _bips) external;

    function undelegateAll() external;

    function governanceVotePower() external view returns (IGovernanceVotePower);
}

interface IWNat is IERC20, IVPToken {
    function deposit() external payable;

    function withdraw(uint256) external;
}

