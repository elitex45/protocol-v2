// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

interface IChainlinkAggregator {
  function decimals() external view returns (uint8);

  function latestAnswer() external view returns (int256);
}
