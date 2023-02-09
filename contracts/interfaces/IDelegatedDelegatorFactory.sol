// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IDelegatedDelegatorFactory {
    event Created(address indexed instance, address indexed creator);

    struct NamedInstance {
        address instance;
        string description;
    }

    function create(string calldata description) external returns (address instance);
    function creatorOf(address instance) external view returns (address);
    function count(address creator) external view returns (uint256);
    function get(address creator, uint256 i) external view returns (address instance, string memory description);
    function getAll(address creator) external view returns (NamedInstance[] memory);
    function rename(address instance, string calldata description) external;
    function remove(address instance) external;
}
