import { expect } from 'chai';
import { constants, ContractFactory } from 'ethers';
import { ethers, upgrades } from 'hardhat';

import { PlushCoreToken } from '../../../types';

describe('PlushCoreToken', () => {
  let PlushCoreTokenFactory: ContractFactory;
  let signer: { address: any }[];
  let plushCoreToken: PlushCoreToken;

  it('Deploy contract', async () => {
    PlushCoreTokenFactory = await ethers.getContractFactory('PlushCoreToken');
    signer = await ethers.getSigners();
    plushCoreToken = (await upgrades.deployProxy(PlushCoreTokenFactory, {
      kind: 'uups',
    })) as PlushCoreToken;
    await plushCoreToken.deployed();
  });

  it('Checking role assignments', async () => {
    expect(
      await plushCoreToken.hasRole(constants.HashZero, signer[0].address),
    ).to.eql(true); // ADMIN role
    expect(
      await plushCoreToken.hasRole(
        '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',
        signer[0].address,
      ),
    ).to.eql(true); // MINTER role
    expect(
      await plushCoreToken.hasRole(
        '0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a',
        signer[0].address, // PAUSER role
      ),
    ).to.eql(true);
    expect(
      await plushCoreToken.hasRole(
        '0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3',
        signer[0].address, // UPGRADER role
      ),
    ).to.eql(true);
  });

  it('Check pause', async () => {
    const pauseContract = await plushCoreToken.pause();
    await pauseContract.wait();
    expect(await plushCoreToken.paused()).to.eql(true);
    const onpauseContract = await plushCoreToken.unpause();
    await onpauseContract.wait();
  });

  it('Check upgrade', async () => {
    const plushCoreTokenNEW = (await upgrades.upgradeProxy(
      plushCoreToken.address,
      PlushCoreTokenFactory,
      { kind: 'uups' },
    )) as PlushCoreToken;
    await plushCoreTokenNEW.deployed();
    expect(plushCoreTokenNEW.address).to.eq(plushCoreToken.address);
  });
});
