import { expect } from 'chai';
import { BigNumber, constants, ContractFactory, Signer } from 'ethers';
import { ethers, upgrades, waffle } from 'hardhat';

import {
  Plush,
  PlushApps,
  PlushAccounts,
  PlushController,
  LifeSpan,
  PlushFaucet,
  PlushGetLifeSpan,
  WrappedPlush,
} from '../types';

const MINTER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('MINTER_ROLE'),
);
const PAUSER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('PAUSER_ROLE'),
);
const UPGRADER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('UPGRADER_ROLE'),
);
const OPERATOR_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('OPERATOR_ROLE'),
);
const STAFF_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('STAFF_ROLE'),
);

describe('Launching the testing of the Plush Protocol', () => {
  let signers: Signer[];

  async function addSigners() {
    [...signers] = await ethers.getSigners();
  }

  addSigners();

  let PlushFactory: ContractFactory;
  let plushToken: Plush;

  let WrappedPlushFactory: ContractFactory;
  let wrappedPlush: WrappedPlush;

  let LifeSpanFactory: ContractFactory;
  let lifeSpan: LifeSpan;

  let PlushGetLifeSpanFactory: ContractFactory;
  let plushGetLifeSpan: PlushGetLifeSpan;
  const plushGetLifeSpanRandomSafeAddress = ethers.Wallet.createRandom();

  let PlushAppsFactory: ContractFactory;
  let plushApps: PlushApps;

  let PlushAccountsFactory: ContractFactory;
  let plushAccounts: PlushAccounts;
  const plushAccountsRandomSafeAddress = ethers.Wallet.createRandom();

  let PlushControllerFactory: ContractFactory;
  let plushController: PlushController;

  let PlushFaucetFactory: ContractFactory;
  let plushFaucet: PlushFaucet;
  const plushFaucetRandomReceiverAddress = ethers.Wallet.createRandom();

  it('[Deploy contract] Plush', async () => {
    PlushFactory = await ethers.getContractFactory('Plush');
    plushToken = (await PlushFactory.deploy()) as Plush;
    await plushToken.deployed();
  });

  it('[Deploy contract] WrappedPlush', async () => {
    WrappedPlushFactory = await ethers.getContractFactory('WrappedPlush');
    wrappedPlush = (await WrappedPlushFactory.deploy(
      plushToken.address,
    )) as WrappedPlush;
    await wrappedPlush.deployed();
  });

  it('[Deploy contract] LifeSpan', async () => {
    LifeSpanFactory = await ethers.getContractFactory('LifeSpan');
    lifeSpan = (await upgrades.deployProxy(LifeSpanFactory, {
      kind: 'uups',
    })) as LifeSpan;
    await lifeSpan.deployed();
  });

  it('[Deploy contract] PlushGetLifeSpan', async () => {
    PlushGetLifeSpanFactory = await ethers.getContractFactory(
      'PlushGetLifeSpan',
    );
    plushGetLifeSpan = (await upgrades.deployProxy(
      PlushGetLifeSpanFactory,
      [lifeSpan.address, await signers[1].getAddress()],
      {
        kind: 'uups',
      },
    )) as PlushGetLifeSpan;
    await plushGetLifeSpan.deployed();
  });

  it('[Deploy contract] PlushApps', async () => {
    PlushAppsFactory = await ethers.getContractFactory('PlushApps');
    plushApps = (await upgrades.deployProxy(PlushAppsFactory, {
      kind: 'uups',
    })) as PlushApps;
    await plushApps.deployed();
  });

  it('[Deploy contract] PlushAccounts', async () => {
    PlushAccountsFactory = await ethers.getContractFactory('PlushAccounts');
    plushAccounts = (await upgrades.deployProxy(
      PlushAccountsFactory,
      [
        plushToken.address,
        plushApps.address,
        plushAccountsRandomSafeAddress.address,
      ],
      {
        kind: 'uups',
      },
    )) as PlushAccounts;
    await plushAccounts.deployed();
  });

  it('[Deploy contract] Test controller', async () => {
    PlushControllerFactory = await ethers.getContractFactory('PlushController');
    plushController = (await upgrades.deployProxy(
      PlushControllerFactory,
      [plushToken.address, plushAccounts.address],
      {
        kind: 'uups',
      },
    )) as PlushController;
    await plushController.deployed();
  });

  it('[Deploy contract] PlushFaucet', async () => {
    PlushFaucetFactory = await ethers.getContractFactory('PlushFaucet');
    plushFaucet = (await upgrades.deployProxy(
      PlushFaucetFactory,
      [plushToken.address, lifeSpan.address, plushAccounts.address],
      {
        kind: 'uups',
      },
    )) as PlushFaucet;
    await plushFaucet.deployed();
  });

  it('Plush -> Check total supply', async () => {
    expect(await plushToken.totalSupply()).to.eql(
      ethers.utils.parseUnits('10000000000', 18),
    ); // Checking that 10 billion tokens were minted
  });

  it('Plush -> Check user balance', async () => {
    expect(await plushToken.balanceOf(await signers[0].getAddress())).to.eql(
      await plushToken.totalSupply(),
    ); // Checking that the tokens have been sent to the test wallet
  });

  it('Plush -> Check transfer', async () => {
    const transferTokens = await plushToken.transfer(
      await signers[1].getAddress(),
      ethers.utils.parseUnits('1', 18),
    );
    await transferTokens.wait();
    expect(await plushToken.balanceOf(await signers[1].getAddress())).to.eql(
      ethers.utils.parseUnits('1', 18),
    ); // Checking the sending of tokens
  });

  it('Plush -> Check burning tokens', async () => {
    const burnTokens = await plushToken.burn(ethers.utils.parseUnits('1', 18));
    await burnTokens.wait();
    expect(await plushToken.balanceOf(await signers[0].getAddress())).to.eql(
      ethers.utils.parseUnits('9999999998', 18),
    ); // Checking the burning of a single token
  });

  it('Plush -> Check setting approve', async () => {
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

  it('Plush -> Check transfer from other wallet with set approve', async () => {
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

  it('WrappedPlush -> Check Plush address', async () => {
    expect(await wrappedPlush.underlying()).to.eql(plushToken.address);
    // Checking that the connection between the contracts has been established
  });

  it('WrappedPlush -> Check total supply', async () => {
    expect(await wrappedPlush.totalSupply()).to.eql(
      ethers.utils.parseUnits('0', 18),
    ); // Checking that zero tokens were minted
  });

  it('WrappedPlush -> Check wrapping', async () => {
    const setAllowance = await plushToken.approve(
      wrappedPlush.address,
      ethers.utils.parseUnits('3', 18),
    );
    await setAllowance.wait();

    const wrappingTokens = await wrappedPlush.depositFor(
      await signers[0].getAddress(),
      ethers.utils.parseUnits('3', 18),
    );
    await wrappingTokens.wait();

    expect(await wrappedPlush.balanceOf(await signers[0].getAddress())).to.eql(
      ethers.utils.parseUnits('3', 18),
    ); // Checking that user has 3 wrapped tokens.

    expect(await plushToken.balanceOf(await signers[0].getAddress())).to.eql(
      ethers.utils.parseUnits('9999999994', 18),
    ); // Checking that the number of Plush tokens has decreased
  });

  it('WrappedPlush -> Check unwrapping', async () => {
    const unwrappingTokens = await wrappedPlush.withdrawTo(
      await signers[0].getAddress(),
      ethers.utils.parseUnits('1', 18),
    );
    await unwrappingTokens.wait();

    expect(await plushToken.balanceOf(await signers[0].getAddress())).to.eql(
      ethers.utils.parseUnits('9999999995', 18),
    );
    expect(await wrappedPlush.balanceOf(await signers[0].getAddress())).to.eql(
      ethers.utils.parseUnits('2', 18),
    );
  });

  it('WrappedPlush -> Check burning', async () => {
    const burningTokens = await wrappedPlush.burn(
      ethers.utils.parseUnits('1', 18),
    );
    await burningTokens.wait();

    expect(await wrappedPlush.balanceOf(await signers[0].getAddress())).to.eql(
      ethers.utils.parseUnits('1', 18),
    );
  });

  it('WrappedPlush -> Check delegate', async () => {
    const depositTokens = await wrappedPlush.delegate(
      await signers[1].getAddress(),
    );
    await depositTokens.wait();

    // add checks after delegate
  });

  it('LifeSpan -> Check total supply', async () => {
    expect(await lifeSpan.totalSupply()).to.eql(ethers.constants.Zero); // ADMIN role
  });

  it('LifeSpan -> Checking role assignments', async () => {
    expect(
      await lifeSpan.hasRole(constants.HashZero, await signers[0].getAddress()),
    ).to.eql(true); // ADMIN role
    expect(
      await lifeSpan.hasRole(MINTER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await lifeSpan.hasRole(PAUSER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await lifeSpan.hasRole(
        UPGRADER_ROLE,
        await signers[0].getAddress(), // UPGRADER role
      ),
    ).to.eql(true);
  });

  it('LifeSpan -> Checking grant role', async () => {
    const grantMinterRole = await lifeSpan.grantRole(
      MINTER_ROLE,
      await signers[1].getAddress(),
    );
    await grantMinterRole.wait();
    expect(
      await lifeSpan.hasRole(MINTER_ROLE, await signers[1].getAddress()),
    ).to.eql(true);
  });

  it('LifeSpan -> Check mint with granted role', async () => {
    const mintToken = await lifeSpan
      .connect(signers[1])
      .safeMint(await signers[1].getAddress());
    await mintToken.wait();
    expect(await lifeSpan.balanceOf(await signers[1].getAddress())).to.eql(
      constants.One,
    );
  });

  it('LifeSpan -> revoke role', async () => {
    const revokeMinterRole = await lifeSpan.revokeRole(
      MINTER_ROLE,
      await signers[1].getAddress(),
    );
    await revokeMinterRole.wait();
    expect(
      await lifeSpan.hasRole(MINTER_ROLE, await signers[1].getAddress()),
    ).to.eql(false);
  });

  it('LifeSpan -> Check pause contract', async () => {
    const pauseContract = await lifeSpan.pause();
    await pauseContract.wait();
    expect(await lifeSpan.paused()).to.eql(true);
    const onpauseContract = await lifeSpan.unpause();
    await onpauseContract.wait();
  });

  it('LifeSpan -> Check upgrade contract', async () => {
    const lifeSpanNEW = (await upgrades.upgradeProxy(
      lifeSpan.address,
      LifeSpanFactory,
      { kind: 'uups' },
    )) as LifeSpan;
    await lifeSpanNEW.deployed();
    expect(lifeSpanNEW.address).to.eq(lifeSpan.address);
    expect(await lifeSpan.totalSupply()).to.eql(constants.One);
  });

  it('PlushGetLifeSpan -> Checking role assignments', async () => {
    expect(
      await plushGetLifeSpan.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushGetLifeSpan.hasRole(STAFF_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await plushGetLifeSpan.hasRole(
        OPERATOR_ROLE,
        await signers[0].getAddress(),
      ),
    ).to.eql(true);
    expect(
      await plushGetLifeSpan.hasRole(
        PAUSER_ROLE,
        await signers[0].getAddress(),
      ),
    ).to.eql(true);
    expect(
      await plushGetLifeSpan.hasRole(
        UPGRADER_ROLE,
        await signers[0].getAddress(),
      ),
    ).to.eql(true);
  });

  it('PlushGetLifeSpan -> Grant minter in LifeSpan contract', async () => {
    const grantRole = await lifeSpan.grantRole(
      MINTER_ROLE,
      plushGetLifeSpan.address,
    );
    await grantRole.wait();
    expect(
      await lifeSpan.hasRole(MINTER_ROLE, plushGetLifeSpan.address),
    ).to.eql(true);
  });

  it('PlushGetLifeSpan -> Check LifeSpan token address', async () => {
    expect(await plushGetLifeSpan.getLifeSpanTokenAddress()).to.eql(
      lifeSpan.address,
    );
  });

  it('PlushGetLifeSpan -> Check safe address', async () => {
    expect(await plushGetLifeSpan.getSafeAddress()).to.eql(
      await signers[1].getAddress(),
    );
  });

  it('PlushGetLifeSpan -> Check mint price', async () => {
    expect(await plushGetLifeSpan.getMintPrice()).to.eql(
      ethers.utils.parseUnits('0.001', 18),
    );
  });

  it('PlushGetLifeSpan -> Change mint price', async () => {
    const changeMintPrice = await plushGetLifeSpan.changeMintPrice(
      ethers.utils.parseUnits('0.0001', 18),
    );
    await changeMintPrice.wait();

    expect(await plushGetLifeSpan.getMintPrice()).to.eql(
      ethers.utils.parseUnits('0.0001', 18),
    );
  });

  it('PlushGetLifeSpan -> Change safe address', async () => {
    const changeSafeAddress = await plushGetLifeSpan.setSafeAddress(
      plushGetLifeSpanRandomSafeAddress.address,
    );
    await changeSafeAddress.wait();

    expect(await plushGetLifeSpan.getSafeAddress()).to.eql(
      plushGetLifeSpanRandomSafeAddress.address,
    );
  });

  it('PlushGetLifeSpan -> Check minting', async () => {
    const mintToken = await plushGetLifeSpan.mint(
      await signers[0].getAddress(),
      { value: ethers.utils.parseUnits('0.0001', 18) },
    );
    await mintToken.wait();

    expect(await lifeSpan.balanceOf(await signers[0].getAddress())).to.eql(
      constants.One,
    );

    const provider = waffle.provider;

    const withdrawTokens = await plushGetLifeSpan.withdraw(
      ethers.utils.parseUnits('0.0001', 18),
    );

    await withdrawTokens.wait();

    const getNewSafeBalance = await provider
      .getBalance(plushGetLifeSpanRandomSafeAddress.address)
      .then((balance) => {
        return ethers.utils.formatEther(balance);
      });

    expect(getNewSafeBalance).to.eql('0.0001');
  });

  it('PlushGetLifeSpan -> Check free minting', async () => {
    await expect(
      plushGetLifeSpan
        .connect(signers[1])
        .freeMint(await signers[1].getAddress()),
    ).to.be.reverted;

    const grantRole = await plushGetLifeSpan.grantRole(
      STAFF_ROLE,
      await signers[1].getAddress(),
    );
    await grantRole.wait();
    expect(
      await plushGetLifeSpan.hasRole(STAFF_ROLE, await signers[1].getAddress()),
    ).to.eql(true);

    const randomAddress = ethers.Wallet.createRandom();

    const mintToken = await plushGetLifeSpan
      .connect(signers[1])
      .freeMint(randomAddress.address);
    await mintToken.wait();

    expect(await lifeSpan.balanceOf(randomAddress.address)).to.eql(
      constants.One,
    );
  });

  it('PlushGetLifeSpan -> Check pause contract', async () => {
    const pauseContract = await plushGetLifeSpan.pause();
    await pauseContract.wait();
    expect(await plushGetLifeSpan.paused()).to.eql(true);
    const onpauseContract = await plushGetLifeSpan.unpause();
    await onpauseContract.wait();
  });

  it('PlushGetLifeSpan -> Check upgrade contract', async () => {
    const plushGetLifeSpanNEW = (await upgrades.upgradeProxy(
      plushGetLifeSpan.address,
      PlushGetLifeSpanFactory,
      { kind: 'uups' },
    )) as PlushGetLifeSpan;
    await plushGetLifeSpanNEW.deployed();
    expect(plushGetLifeSpanNEW.address).to.eq(plushGetLifeSpan.address);
    expect(await lifeSpan.totalSupply()).to.eql(BigNumber.from('3'));
  });

  it('PlushApps -> Checking role assignments', async () => {
    expect(
      await plushApps.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushApps.hasRole(OPERATOR_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await plushApps.hasRole(PAUSER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await plushApps.hasRole(UPGRADER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
  });

  it('PlushApps -> Add test app', async () => {
    const addApp = await plushApps.addNewApp(
      'test',
      plushController.address,
      '50',
    );
    await addApp.wait();

    expect(await plushApps.getFeeApp(plushController.address)).to.eql(
      BigNumber.from('50'),
    );
  });

  it('PlushApps -> Change fee app', async () => {
    const changingFee = await plushApps.setFeeApp(
      plushController.address,
      '100',
    );
    await changingFee.wait();

    expect(await plushApps.getFeeApp(plushController.address)).to.eql(
      BigNumber.from('100'),
    );
  });

  it('PlushApps -> Test disable app', async () => {
    const disableApp = await plushApps.setIsActive(
      false,
      plushController.address,
    );
    await disableApp.wait();

    expect(await plushApps.getIsAddressActive(plushController.address)).to.eql(
      false,
    );

    // add test some activity with controller

    const enableApp = await plushApps.setIsActive(
      true,
      plushController.address,
    );
    await enableApp.wait();
  });

  it('PlushApps -> Check pause contract', async () => {
    const pauseContract = await plushApps.pause();
    await pauseContract.wait();
    expect(await plushApps.paused()).to.eql(true);
    const onpauseContract = await plushApps.unpause();
    await onpauseContract.wait();
  });

  it('PlushApps -> Check upgrade contract', async () => {
    const plushAppsNEW = (await upgrades.upgradeProxy(
      plushApps.address,
      PlushAppsFactory,
      { kind: 'uups' },
    )) as PlushApps;
    await plushAppsNEW.deployed();
    expect(plushAppsNEW.address).to.eq(plushApps.address);
  });

  it('PlushFaucet -> Checking role assignments', async () => {
    expect(
      await plushFaucet.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushFaucet.hasRole(OPERATOR_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await plushFaucet.hasRole(PAUSER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await plushFaucet.hasRole(UPGRADER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
  });

  it('PlushFaucet -> Checking initial values', async () => {
    expect(await plushFaucet.getDistributionTime()).to.eql(
      BigNumber.from('86400'),
    ); // 24 hours

    expect(await plushFaucet.getFaucetDripAmount()).to.eql(
      ethers.utils.parseUnits('1', 18),
    ); // 1 Plush

    expect(await plushFaucet.getThreshold()).to.eql(
      ethers.utils.parseUnits('100', 18),
    ); // Max Plush user balance

    expect(await plushFaucet.getIsTokenNFTCheck()).to.eql(true); // NFT check

    expect(await plushFaucet.getFaucetBalance()).to.eql(ethers.constants.Zero); // Check Faucet balance
  });

  it('PlushFaucet -> Add tokens to faucet', async () => {
    const setApprove = await plushToken.approve(
      plushFaucet.address,
      ethers.utils.parseUnits('3', 18),
    );
    await setApprove.wait();

    const transferTokens = await plushToken.transfer(
      plushFaucet.address,
      ethers.utils.parseUnits('3', 18),
    );
    await transferTokens.wait();

    expect(await plushFaucet.getFaucetBalance()).to.eql(
      ethers.utils.parseUnits('3', 18),
    );
  });

  it('PlushFaucet -> Get tokens from faucet to PlushAccounts', async () => {
    expect(
      await plushFaucet.getCanTheAddressReceiveReward(
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // Check that we can to get tokens

    const getTokens = await plushFaucet.send(await signers[0].getAddress());
    await getTokens.wait();

    expect(await plushFaucet.getFaucetBalance()).to.eql(
      ethers.utils.parseUnits('2', 18),
    );
    expect(
      await plushAccounts.getWalletAmount(await signers[0].getAddress()),
    ).to.eql(ethers.utils.parseUnits('1', 18)); // Check that we to get one token on Safe contract
  });

  it("PlushFaucet -> Check that we can't to get tokens twice", async () => {
    await expect(
      plushFaucet.getCanTheAddressReceiveReward(await signers[0].getAddress()),
    ).to.be.revertedWith('Time limit');
  });

  it('PlushFaucet -> Set disable NFT checking', async () => {
    const changeNFTCheck = await plushFaucet.setTokenNFTCheck(false);
    await changeNFTCheck.wait();
    expect(await plushFaucet.getIsTokenNFTCheck()).to.eql(false);
  });

  it('PlushFaucet -> Try to get tokens without NFT (with disable NFT checking)', async () => {
    const getTokens = await plushFaucet.send(
      plushFaucetRandomReceiverAddress.address,
    );
    await getTokens.wait();
    expect(
      await plushAccounts.getWalletAmount(
        plushFaucetRandomReceiverAddress.address,
      ),
    ).to.eql(ethers.utils.parseUnits('1', 18));
    await expect(
      plushFaucet.getCanTheAddressReceiveReward(
        plushFaucetRandomReceiverAddress.address,
      ),
    ).to.be.revertedWith('Time limit');
  });

  it('PlushFaucet -> Withdraw tokens from faucet', async () => {
    const withdrawTokens = await plushFaucet.withdrawTokens(
      plushFaucetRandomReceiverAddress.address,
      ethers.utils.parseUnits('1', 18),
    );
    await withdrawTokens.wait();

    expect(
      await plushToken.balanceOf(plushFaucetRandomReceiverAddress.address),
    ).to.eql(ethers.utils.parseUnits('1', 18));
    expect(await plushFaucet.getFaucetBalance()).to.eql(
      ethers.utils.parseUnits('0', 18),
    );
  });

  it('PlushFaucet -> Check pause contract', async () => {
    const pauseContract = await plushFaucet.pause();
    await pauseContract.wait();
    expect(await plushFaucet.paused()).to.eql(true);
    const onpauseContract = await plushFaucet.unpause();
    await onpauseContract.wait();
    expect(await plushFaucet.paused()).to.eql(false);
  });

  it('PlushFaucet -> Check upgrade contract', async () => {
    const plushFaucetNEW = (await upgrades.upgradeProxy(
      plushFaucet.address,
      PlushFaucetFactory,
      { kind: 'uups' },
    )) as PlushFaucet;
    await plushFaucetNEW.deployed();
    expect(plushFaucetNEW.address).to.eq(plushFaucet.address);
  });

  it('PlushAccounts -> Checking role assignments', async () => {
    expect(
      await plushFaucet.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushFaucet.hasRole(OPERATOR_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await plushFaucet.hasRole(PAUSER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await plushFaucet.hasRole(UPGRADER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
  });

  it('PlushAccounts -> Checking initial values', async () => {
    expect(await plushAccounts.plushApps()).to.eql(plushApps.address);
    expect(await plushAccounts.plush()).to.eql(plushToken.address);
    expect(await plushAccounts.minimumDeposit()).to.eql(
      ethers.utils.parseUnits('1', 18),
    );
    expect(await plushAccounts.getPlushFeeAddress()).to.eql(
      plushAccountsRandomSafeAddress.address,
    );
  });

  it('PlushAccounts -> Check user balances', async () => {
    expect(
      await plushAccounts.getWalletAmount(await signers[0].getAddress()),
    ).to.eql(ethers.utils.parseUnits('1', 18));
  });

  it('PlushAccounts -> Check transfer tokens in safe', async () => {
    const transferTokens = await plushAccounts.internalTransfer(
      await signers[1].getAddress(),
      ethers.utils.parseUnits('1', 18),
    );
    await transferTokens.wait();
    expect(
      await plushAccounts.getWalletAmount(await signers[0].getAddress()),
    ).to.eql(ethers.utils.parseUnits('0', 18));
    expect(
      await plushAccounts.getWalletAmount(await signers[1].getAddress()),
    ).to.eql(ethers.utils.parseUnits('1', 18));
  });

  it('PlushAccounts -> Check pause contract', async () => {
    const pauseContract = await plushAccounts.pause();
    await pauseContract.wait();
    expect(await plushAccounts.paused()).to.eql(true);
    const onpauseContract = await plushAccounts.unpause();
    await onpauseContract.wait();
    expect(await plushAccounts.paused()).to.eql(false);
  });

  it('PlushAccounts -> Check upgrade contract', async () => {
    const plushAccountsNEW = (await upgrades.upgradeProxy(
      plushAccounts.address,
      PlushAccountsFactory,
      { kind: 'uups' },
    )) as PlushAccounts;
    await plushAccountsNEW.deployed();
    expect(plushAccountsNEW.address).to.eq(plushAccounts.address);
    expect(
      await plushAccounts.getWalletAmount(await signers[1].getAddress()),
    ).to.eql(ethers.utils.parseUnits('1', 18));
  });
});
