import { expect } from 'chai';
import { constants, ContractFactory } from 'ethers';
import { ethers, upgrades } from 'hardhat';

import { PlushApps } from '../types';

describe('PlushApps', () => {
  let PlushAppsFactory: ContractFactory;
  let signer: { address: any }[];
  let plushApps: PlushApps;

  it('Deploy contract', async () => {
    PlushAppsFactory = await ethers.getContractFactory('PlushApps');
    signer = await ethers.getSigners();
    plushApps = (await upgrades.deployProxy(PlushAppsFactory, {
      kind: 'uups',
    })) as PlushApps;
    await plushApps.deployed();
  });

  it('Checking role assignments', async () => {
    expect(
      await plushApps.hasRole(constants.HashZero, signer[0].address),
    ).to.eql(true); // ADMIN role
    expect(
      await plushApps.hasRole(
        '0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929',
        signer[0].address, // OPERATOR role
      ),
    ).to.eql(true);
    expect(
      await plushApps.hasRole(
        '0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a',
        signer[0].address, // PAUSER role
      ),
    ).to.eql(true);
    expect(
      await plushApps.hasRole(
        '0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3',
        signer[0].address, // UPGRADER role
      ),
    ).to.eql(true);
  });

  it('Check pause', async () => {
    const pauseContract = await plushApps.pause();
    await pauseContract.wait();
    expect(await plushApps.paused()).to.eql(true);
    const onpauseContract = await plushApps.unpause();
    await onpauseContract.wait();
  });

  it('Check upgrade', async () => {
    const plushAppsNEW = (await upgrades.upgradeProxy(
      plushApps.address,
      PlushAppsFactory,
      { kind: 'uups' },
    )) as PlushApps;
    await plushAppsNEW.deployed();
    expect(plushAppsNEW.address).to.eq(plushApps.address);
  });
});
