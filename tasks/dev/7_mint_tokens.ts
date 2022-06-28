import { task } from 'hardhat/config';
import { getMintableERC20, getAllMockedTokens } from '../../helpers/contracts-getters';
import { getAllTokenAddresses } from '../../helpers/mock-helpers';
import { waitForTx, filterMapBy, notFalsyOrZeroAddress } from '../../helpers/misc-utils';
import { tEthereumAddress, AavePools, eContractid } from '../../helpers/types';
import { ethers } from 'ethers';

task('mint-tokens-mock', 'Mint Mock tokens to admin address').setAction(async ({}, localBRE) => {
  await localBRE.run('set-DRE');
  const mockTokens = await getAllMockedTokens();
  const allTokenAddresses = getAllTokenAddresses(mockTokens);

  const protoPoolReservesAddresses = <{ [symbol: string]: tEthereumAddress }>(
    filterMapBy(allTokenAddresses, (key: string) => !key.includes('Uni') && !key.includes('Bpt'))
  );

  console.log(protoPoolReservesAddresses);

  for (var token in protoPoolReservesAddresses) {
    const erc = await getMintableERC20(allTokenAddresses[token]);
    await waitForTx(await erc.mint(ethers.utils.parseEther('1000')));
    console.log('key:', token, 'address', allTokenAddresses[token]);
  }
});
