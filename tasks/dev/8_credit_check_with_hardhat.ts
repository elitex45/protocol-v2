import { task } from 'hardhat/config';
import {
  getMintableERC20,
  getAllMockedTokens,
  getLendingPool,
  getAaveProtocolDataProvider,
  getCreditTokenNew,
} from '../../helpers/contracts-getters';
import { getAllTokenAddresses } from '../../helpers/mock-helpers';
import { waitForTx, filterMapBy, notFalsyOrZeroAddress } from '../../helpers/misc-utils';
import { tEthereumAddress, AavePools, eContractid } from '../../helpers/types';
import { ethers } from 'ethers';
import { getEthersSigners } from '../../helpers/contracts-helpers';
import { APPROVAL_AMOUNT_LENDING_POOL } from '../../helpers/constants';
import { RateMode, ProtocolErrors } from '../../helpers/types';
import { formatEther, parseEther, parseUnits } from 'ethers/lib/utils';

task('credit-check', 'Mint Mock tokens to admin address').setAction(async ({}, localBRE) => {
  await localBRE.run('set-DRE');
  const [_deployer, ...restSigners] = await getEthersSigners();
  const deployer = {
    address: await _deployer.getAddress(),
    signer: _deployer,
  };
  const users = Array();
  for (const signer of restSigners) {
    users.push({
      signer,
      address: await signer.getAddress(),
    });
  }

  console.log('user: ', deployer.address);

  const helpersContract = await getAaveProtocolDataProvider();
  const reservesTokens = await helpersContract.getAllReservesTokens();
  const daiAddress = reservesTokens.find((token) => token.symbol === 'DAI')?.tokenAddress;
  const pool = await getLendingPool();
  if (!daiAddress) {
    process.exit(1);
  }
  const dai = await getMintableERC20(daiAddress);
  const amountArbitrary = ethers.utils.parseEther('100000000');
  const amountArbitraryDeposit = ethers.utils.parseEther('10000000');
  const amountArbitraryBorrow = ethers.utils.parseEther('10000000');

  await dai.connect(deployer.signer).mint(amountArbitrary);
  await dai.connect(deployer.signer).approve(pool.address, APPROVAL_AMOUNT_LENDING_POOL);

  const poolContractInstance = await pool.connect(deployer.signer);
  await poolContractInstance.deposit(daiAddress, amountArbitraryDeposit, deployer.address, '0');

  for (let i = 0; i < 10; i++) {
    console.log('Loop :', i);

    await poolContractInstance.borrow(
      daiAddress,
      amountArbitraryBorrow,
      RateMode.Variable,
      '0',
      deployer.address
    );
    await poolContractInstance.repay(
      daiAddress,
      amountArbitraryBorrow,
      RateMode.Variable,
      deployer.address
    );

    const reserveData = await poolContractInstance.getReserveData(daiAddress);
    const userAccountData = await poolContractInstance.getUserAccountData(deployer.address);
    console.log(
      'user totalDebt in ETH after repay',
      formatEther(userAccountData.totalDebtETH.toString())
    );
    console.log(
      'user creditBalance in ETH after repay',
      formatEther(userAccountData.totalCreditInEth.toString())
    );
    console.log(
      'user availableBorrows in ETH after repay',
      formatEther(userAccountData.availableBorrowsETH.toString())
    );

    const creditTokenAddr = reserveData.creditTokensAddress;
    const creditToken = await getCreditTokenNew(creditTokenAddr);
    const creditBalance = await creditToken.balanceOf(deployer.address);
    console.log('credit balance of user[0] after repaying', formatEther(creditBalance.toString()));
  }
});
