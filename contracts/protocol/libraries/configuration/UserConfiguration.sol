/*we need to change all the functions in this file because we are spliting the bit map as groupof 3
  instead of group of two (which is done by aave)
  1st bit represent whether the user is using this asset as a collateral or not
  2nd bit represents whether the user is borrowing that asset or not
  3rd bit represents whether the user has credits in that asset or not
*/
// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;

import {Errors} from '../helpers/Errors.sol';
import {DataTypes} from '../types/DataTypes.sol';

/**
 * @title UserConfiguration library
 * @author Aave
 * @notice Implements the bitmap logic to handle the user configuration
 */
library UserConfiguration {
  uint256 internal constant BORROWING_MASK =
    0xDB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6DB6D;

  uint256 internal constant CREDIT_MASK =
    0xC924924924924924924924924924924924924924924924924924924924924924;

  /**
   * @dev Sets if the user is borrowing the reserve identified by reserveIndex
   * @param self The configuration object
   * @param reserveIndex The index of the reserve in the bitmap
   * @param borrowing True if the user is borrowing the reserve, false otherwise
   **/
  function setBorrowing(
    DataTypes.UserConfigurationMap storage self,
    uint256 reserveIndex,
    bool borrowing
  ) internal {
    require(reserveIndex < 85, Errors.UL_INVALID_INDEX);
    self.data =
      (self.data & ~(1 << (reserveIndex * 3))) |
      (uint256(borrowing ? 1 : 0) << (reserveIndex * 3));
  }

  /**
   * @dev Sets if the user is using as collateral the reserve identified by reserveIndex
   * @param self The configuration object
   * @param reserveIndex The index of the reserve in the bitmap
   * @param usingAsCollateral True if the user is usin the reserve as collateral, false otherwise
   **/
  function setUsingAsCollateral(
    DataTypes.UserConfigurationMap storage self,
    uint256 reserveIndex,
    bool usingAsCollateral
  ) internal {
    require(reserveIndex < 85, Errors.UL_INVALID_INDEX);
    self.data =
      (self.data & ~(1 << (reserveIndex * 3 + 1))) |
      (uint256(usingAsCollateral ? 1 : 0) << (reserveIndex * 3 + 1));
  }

  function setcreditbacked(
    DataTypes.UserConfigurationMap memory self,
    uint256 reserveIndex,
    bool creditbacked
  ) internal {
    require(reserveIndex < 85, Errors.UL_INVALID_INDEX);
    self.data =
      (self.data & ~(1 << (reserveIndex * 3 + 2))) |
      (uint256(creditbacked ? 1 : 0) << (reserveIndex * 3 + 2));
  }

  /*function to get whether the user has credit in the resrve or not
   */
  function hascreditbacked(DataTypes.UserConfigurationMap memory self, uint256 reserveIndex)
    internal
    view
    returns (bool)
  {
    require(reserveIndex < 85, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 3 + 2)) & 1 != 0;
  }

  //function to validate if a user has been using the reserve for borrowing or as collateral or backed
  function isUsingAsCollateralOrBorrowingOrhascredit(
    DataTypes.UserConfigurationMap memory self,
    uint256 reserveIndex
  ) internal pure returns (bool) {
    require(reserveIndex < 85, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 3)) & 7 != 0;
  }

  function HasanyCredit(DataTypes.UserConfigurationMap memory self) internal view returns (bool) {
    return self.data & CREDIT_MASK != 0;
  }

  /**
   * @dev Used to validate if a user has been using the reserve for borrowing or as collateral
   * @param self The configuration object
   * @param reserveIndex The index of the reserve in the bitmap
   * @return True if the user has been using a reserve for borrowing or as collateral, false otherwise
   **/
  function isUsingAsCollateralOrBorrowing(
    DataTypes.UserConfigurationMap memory self,
    uint256 reserveIndex
  ) internal pure returns (bool) {
    require(reserveIndex < 85, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 3)) & 3 != 0;
  }

  /**
   * @dev Used to validate if a user has been using the reserve for borrowing
   * @param self The configuration object
   * @param reserveIndex The index of the reserve in the bitmap
   * @return True if the user has been using a reserve for borrowing, false otherwise
   **/
  function isBorrowing(DataTypes.UserConfigurationMap memory self, uint256 reserveIndex)
    internal
    pure
    returns (bool)
  {
    require(reserveIndex < 85, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 3)) & 1 != 0;
  }

  /**
   * @dev Used to validate if a user has been using the reserve as collateral
   * @param self The configuration object
   * @param reserveIndex The index of the reserve in the bitmap
   * @return True if the user has been using a reserve as collateral, false otherwise
   **/
  function isUsingAsCollateral(DataTypes.UserConfigurationMap memory self, uint256 reserveIndex)
    internal
    pure
    returns (bool)
  {
    require(reserveIndex < 85, Errors.UL_INVALID_INDEX);
    return (self.data >> (reserveIndex * 3 + 1)) & 1 != 0;
  }

  /**
   * @dev Used to validate if a user has been borrowing from any reserve
   * @param self The configuration object
   * @return True if the user has been borrowing any reserve, false otherwise
   **/
  function isBorrowingAny(DataTypes.UserConfigurationMap memory self) internal pure returns (bool) {
    return self.data & BORROWING_MASK != 0;
  }

  /**
   * @dev Used to validate if a user has not been using any reserve
   * @param self The configuration object
   * @return True if the user has been borrowing any reserve, false otherwise
   **/
  function isEmpty(DataTypes.UserConfigurationMap memory self) internal pure returns (bool) {
    return self.data == 0;
  }
}
