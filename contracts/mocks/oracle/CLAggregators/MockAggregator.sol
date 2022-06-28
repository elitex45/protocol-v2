// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;
import {IChainlinkAggregator} from '../interfaces/IChainlinkAggregator.sol';

contract MockAggregator is IChainlinkAggregator {
  int256 private _latestAnswer;

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);

  constructor(int256 _initialAnswer) public {
    _latestAnswer = _initialAnswer;
    emit AnswerUpdated(_initialAnswer, 0, now);
  }

  function latestAnswer() external view override returns (int256) {
    return _latestAnswer;
  }

  function decimals() external view override returns (uint8) {
    return 18;
  }

  // function getSubTokens() external view returns (address[] memory) {
  // TODO: implement mock for when multiple subtokens. Maybe we need to create diff mock contract
  // to call it from the migration for this case??
  // }
}
