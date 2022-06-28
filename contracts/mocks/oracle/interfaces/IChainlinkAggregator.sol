// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

interface IChainlinkAggregator {
  function decimals() external view returns (uint8);

  function latestAnswer() external view returns (int256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
}
