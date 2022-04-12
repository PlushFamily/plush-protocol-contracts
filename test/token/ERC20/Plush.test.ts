import { expect } from 'chai';
import { ContractFactory, Signer } from 'ethers';
import { ethers } from 'hardhat';

import { Plush } from '../../../types';

describe('Plush', () => {
  let PlushFactory: ContractFactory;
  let signers: Signer[];
  let plushToken: Plush;

  it('Deploy contract', async () => {
    PlushFactory = await ethers.getContractFactory('Plush');
    [...signers] = await ethers.getSigners();
    plushToken = (await PlushFactory.deploy()) as Plush;
    await plushToken.deployed();
  });

  it('Check total supply', async () => {
    expect(await plushToken.totalSupply()).to.eql(
      ethers.utils.parseUnits('10000000000', 18),
    ); // Checking that 10 billion tokens were minted
  });

  it('Check user balance', async () => {
    expect(await plushToken.balanceOf(await signers[0].getAddress())).to.eql(
      await plushToken.totalSupply(),
    ); // Checking that the tokens have been sent to the test wallet
  });

  it('Check transfer', async () => {
    const transferTokens = await plushToken.transfer(
      await signers[1].getAddress(),
      ethers.utils.parseUnits('1', 18),
    );
    await transferTokens.wait();
    expect(await plushToken.balanceOf(await signers[1].getAddress())).to.eql(
      ethers.utils.parseUnits('1', 18),
    ); // Checking the sending of tokens
  });

  it('Check burning tokens', async () => {
    const burnTokens = await plushToken.burn(ethers.utils.parseUnits('1', 18));
    await burnTokens.wait();
    expect(await plushToken.balanceOf(await signers[0].getAddress())).to.eql(
      ethers.utils.parseUnits('9999999998', 18),
    ); // Checking the burning of a single token
  });

  it('Check setting approve', async () => {
    const setApproveTokens = await plushToken.approve(
      await signers[1].getAddress(),
      ethers.utils.parseUnits('1', 18),
    );
    await setApproveTokens.wait();
    expect(
      await plushToken.allowance(
        await signers[0].getAddress(),
        await signers[1].getAddress(),
      ),
    ).to.eql(ethers.utils.parseUnits('1', 18)); // Checking the setting of the permission to spend tokens for another address
  });

  it('Check transfer from other wallet with set approve', async () => {
    const transferTokens = await plushToken
      .connect(signers[1])
      .transferFrom(
        await signers[0].getAddress(),
        await signers[1].getAddress(),
        ethers.utils.parseUnits('1', 18),
      );
    await transferTokens.wait();
    expect(await plushToken.balanceOf(await signers[0].getAddress())).to.eql(
      ethers.utils.parseUnits('9999999997', 18),
    ); // Checking the spending of tokens after setting the permission to spend funds
  });
});
