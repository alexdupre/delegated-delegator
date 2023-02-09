// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import './interfaces/IDelegatedDelegatorFactory.sol';
import "./DelegatedDelegator.sol";

contract DelegatedDelegatorFactory is IDelegatedDelegatorFactory {

    mapping(address => NamedInstance[]) private instances;
    mapping(address => address) public creatorOf;

    function create(string calldata description) external returns (address instance) {
        address creator = msg.sender;
        instance = address(new DelegatedDelegator(creator));
        if (bytes(description).length > 0) {
            NamedInstance storage ni = instances[creator].push();
            ni.instance = instance;
            ni.description = description;
        }
        creatorOf[instance] = creator;
        emit Created(instance, creator);
    }

    function count(address creator) external view returns (uint256) {
        return instances[creator].length;
    }

    function get(address creator, uint256 i) external view returns (address instance, string memory description) {
        NamedInstance storage ni = instances[creator][i];
        return (ni.instance, ni.description);
    }

    function getAll(address creator) external view returns (NamedInstance[] memory) {
        return instances[creator];
    }

    function rename(address instance, string calldata description) external {
        require(bytes(description).length > 0, "Empty description");
        NamedInstance[] storage nis = instances[msg.sender];
        for (uint256 i; i < nis.length; i++) {
            if (nis[i].instance == instance) {
                nis[i].description = description;
                return;
            }
        }
        revert("Instance not found");
    }

    function remove(address instance) external {
        NamedInstance[] storage nis = instances[msg.sender];
        for (uint256 i; i < nis.length; i++) {
            if (nis[i].instance == instance) {
                if (i < nis.length - 1) nis[i] = nis[nis.length - 1];
                nis.pop();
                return;
            }
        }
        revert("Instance not found");
    }
}
