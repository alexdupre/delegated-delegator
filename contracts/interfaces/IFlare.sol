// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IFtsoRewardManager {
    function claimReward(
        address payable _recipient,
        uint256[] calldata _rewardEpochs
    ) external returns (uint256 _rewardAmount);

    function claim(
        address _rewardOwner,
        address payable _recipient,
        uint256 _rewardEpoch,
        bool _wrap
    ) external returns (uint256 _rewardAmount);
}

interface RewardsV2Interface {
    enum ClaimType { DIRECT, FEE, WNAT, MIRROR, CCHAIN }

    struct RewardClaimWithProof {
        bytes32[] merkleProof;
        RewardClaim body;
    }

    struct RewardClaim {
        uint24 rewardEpochId;
        bytes20 beneficiary;
        uint120 amount;
        ClaimType claimType;
    }

    function claim(
        address _rewardOwner,
        address payable _recipient,
        uint24 _rewardEpochId,
        bool _wrap,
        RewardClaimWithProof[] calldata _proofs
    ) external returns (uint256 _rewardAmountWei);
}

interface IDistributionToDelegators {
    function claim(address _rewardOwner, address _recipient, uint256 _month, bool _wrap) external returns(uint256 _rewardAmount);
}

interface IERC20 {
    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
}

interface IGovernanceVotePower {
    function delegate(address _to) external;
}

interface IVPToken {
    function delegatesOf(address _owner) external view returns (address[] memory _delegateAddresses, uint256[] memory _bips, uint256 _count, uint256 _delegationMode);

    function delegate(address _to, uint256 _bips) external;

    function undelegateAll() external;

    function governanceVotePower() external view returns (IGovernanceVotePower);
}

interface IWNat is IERC20, IVPToken {
    function deposit() external payable;

    function withdraw(uint256) external;
}

interface IFlareContractRegistry {
    function getContractAddressByHash(bytes32 _nameHash) external view returns (address);
}