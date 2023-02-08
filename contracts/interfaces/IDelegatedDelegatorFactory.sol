// SPDX-License-Identifier: MIT
pragma solidity >=0.7.5;
pragma abicoder v2;

interface IDelegatedDelegatorFactory {
    event Created(address indexed instance, address indexed owner);

    struct NamedInstance {
        address instance;
        string description;
    }

    function create(string calldata description) external returns (address instance);
    function count(address owner) external view returns (uint256);
    function get(address owner, uint256 i) external view returns (address instance, string memory description);
    function getAll(address owner) external view returns (NamedInstance[] memory);
    function rename(address instance, string calldata description) external;
    function remove(address instance) external;
}
