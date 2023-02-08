// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import './interfaces/IFlare.sol';

library FlareLibrary {
    IPriceSubmitter private constant priceSubmitter = IPriceSubmitter(0x1000000000000000000000000000000000000003);

    function getWNat() internal view returns (IWNat) {
        return IWNat(IFtsoRewardManager(IFtsoManager(priceSubmitter.getFtsoManager()).rewardManager()).wNat());
    }
}