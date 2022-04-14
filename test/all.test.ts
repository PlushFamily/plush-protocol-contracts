import { expect } from 'chai';
import { BigNumber, constants, ContractFactory, Signer } from 'ethers';
import { ethers, upgrades } from 'hardhat';

import {
  Plush,
  PlushApps,
  PlushCoinWallets,
  PlushController,
  PlushCoreToken,
  PlushFaucet,
  PlushGetCoreToken,
  WrappedPlush,
} from '../types';

describe('Launching the testing of the Plush Protocol', () => {
  let signers: Signer[];

  async function addSigners() {
    [...signers] = await ethers.getSigners();
  }

  addSigners();

  const rpc = 'http://127.0.0.1:7545';

  let PlushFactory: ContractFactory;
  let plushToken: Plush;

  let WrappedPlushFactory: ContractFactory;
  let wrappedPlush: WrappedPlush;

  let PlushCoreTokenFactory: ContractFactory;
  let plushCoreToken: PlushCoreToken;

  let PlushGetCoreTokenFactory: ContractFactory;
  let plushGetCoreToken: PlushGetCoreToken;
  const plushGetCoreTokenRandomSafeAddress = ethers.Wallet.createRandom();

  let PlushAppsFactory: ContractFactory;
  let plushApps: PlushApps;

  let PlushCoinWalletsFactory: ContractFactory;
  let plushCoinWallets: PlushCoinWallets;
  const plushCoinWalletsRandomSafeAddress = ethers.Wallet.createRandom();

  let PlushControllerFactory: ContractFactory;
  let plushController: PlushController;

  let PlushFaucetFactory: ContractFactory;
  let plushFaucet: PlushFaucet;

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

  it('[Deploy contract] PlushCoreToken', async () => {
    PlushCoreTokenFactory = await ethers.getContractFactory('PlushCoreToken');
    plushCoreToken = (await upgrades.deployProxy(PlushCoreTokenFactory, {
      kind: 'uups',
    })) as PlushCoreToken;
    await plushCoreToken.deployed();
  });

  it('[Deploy contract] PlushGetCoreToken', async () => {
    PlushGetCoreTokenFactory = await ethers.getContractFactory(
      'PlushGetCoreToken',
    );
    plushGetCoreToken = (await upgrades.deployProxy(
      PlushGetCoreTokenFactory,
      [plushCoreToken.address, await signers[1].getAddress()],
      {
        kind: 'uups',
      },
    )) as PlushGetCoreToken;
    await plushGetCoreToken.deployed();
  });

  it('[Deploy contract] PlushApps', async () => {
    PlushAppsFactory = await ethers.getContractFactory('PlushApps');
    plushApps = (await upgrades.deployProxy(PlushAppsFactory, {
      kind: 'uups',
    })) as PlushApps;
    await plushApps.deployed();
  });

  it('[Deploy contract] PlushCoinWallets', async () => {
    PlushCoinWalletsFactory = await ethers.getContractFactory(
      'PlushCoinWallets',
    );
    plushCoinWallets = (await upgrades.deployProxy(
      PlushCoinWalletsFactory,
      [
        plushToken.address,
        plushApps.address,
        plushCoinWalletsRandomSafeAddress.address,
      ],
      {
        kind: 'uups',
      },
    )) as PlushCoinWallets;
    await plushCoinWallets.deployed();
  });

  it('[Deploy contract] Test controller', async () => {
    PlushControllerFactory = await ethers.getContractFactory('PlushController');
    plushController = (await upgrades.deployProxy(
      PlushControllerFactory,
      [plushToken.address, plushCoinWallets.address],
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
      [plushToken.address, plushCoreToken.address, plushCoinWallets.address],
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

  it('PlushCoreToken -> Check total supply', async () => {
    expect(await plushCoreToken.totalSupply()).to.eql(ethers.constants.Zero); // ADMIN role
  });

  it('PlushCoreToken -> Checking role assignments', async () => {
    expect(
      await plushCoreToken.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushCoreToken.hasRole(
        '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // MINTER role
    expect(
      await plushCoreToken.hasRole(
        '0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a',
        await signers[0].getAddress(), // PAUSER role
      ),
    ).to.eql(true);
    expect(
      await plushCoreToken.hasRole(
        '0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3',
        await signers[0].getAddress(), // UPGRADER role
      ),
    ).to.eql(true);
  });

  it('PlushCoreToken -> Checking grant role', async () => {
    const grantMinterRole = await plushCoreToken.grantRole(
      '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',
      await signers[1].getAddress(),
    );
    await grantMinterRole.wait();
    expect(
      await plushCoreToken.hasRole(
        '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',
        await signers[1].getAddress(),
      ),
    ).to.eql(true);
  });

  it('PlushCoreToken -> Check mint with granted role', async () => {
    const mintToken = await plushCoreToken
      .connect(signers[1])
      .safeMint(await signers[1].getAddress());
    await mintToken.wait();
    expect(
      await plushCoreToken.balanceOf(await signers[1].getAddress()),
    ).to.eql(constants.One);
  });

  it('PlushCoreToken -> revoke role', async () => {
    const revokeMinterRole = await plushCoreToken.revokeRole(
      '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',
      await signers[1].getAddress(),
    );
    await revokeMinterRole.wait();
    expect(
      await plushCoreToken.hasRole(
        '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',
        await signers[1].getAddress(),
      ),
    ).to.eql(false);
  });

  it('PlushCoreToken -> Check pause contract', async () => {
    const pauseContract = await plushCoreToken.pause();
    await pauseContract.wait();
    expect(await plushCoreToken.paused()).to.eql(true);
    const onpauseContract = await plushCoreToken.unpause();
    await onpauseContract.wait();
  });

  it('PlushCoreToken -> Check upgrade contract', async () => {
    const plushCoreTokenNEW = (await upgrades.upgradeProxy(
      plushCoreToken.address,
      PlushCoreTokenFactory,
      { kind: 'uups' },
    )) as PlushCoreToken;
    await plushCoreTokenNEW.deployed();
    expect(plushCoreTokenNEW.address).to.eq(plushCoreToken.address);
    expect(await plushCoreToken.totalSupply()).to.eql(constants.One);
  });

  it('PlushGetCoreToken -> Checking role assignments', async () => {
    expect(
      await plushGetCoreToken.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushGetCoreToken.hasRole(
        '0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929',
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // OPERATOR role
    expect(
      await plushGetCoreToken.hasRole(
        '0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a',
        await signers[0].getAddress(), // PAUSER role
      ),
    ).to.eql(true);
    expect(
      await plushGetCoreToken.hasRole(
        '0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3',
        await signers[0].getAddress(), // UPGRADER role
      ),
    ).to.eql(true);
  });

  it('PlushGetCoreToken -> Grant minter in PlushCoreToken contract', async () => {
    const grantRole = await plushCoreToken.grantRole(
      '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',
      plushGetCoreToken.address,
    );
    await grantRole.wait();
    expect(
      await plushCoreToken.hasRole(
        '0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6',
        plushGetCoreToken.address,
      ),
    ).to.eql(true);
  });

  it('PlushGetCoreToken -> Check Core token address', async () => {
    expect(await plushGetCoreToken.getCoreTokenAddress()).to.eql(
      plushCoreToken.address,
    );
  });

  it('PlushGetCoreToken -> Check safe address', async () => {
    expect(await plushGetCoreToken.getSafeAddress()).to.eql(
      await signers[1].getAddress(),
    );
  });

  it('PlushGetCoreToken -> Check mint price', async () => {
    expect(await plushGetCoreToken.getMintPrice()).to.eql(
      ethers.utils.parseUnits('0.001', 18),
    );
  });

  it('PlushGetCoreToken -> Change mint price', async () => {
    const changeMintPrice = await plushGetCoreToken.changeMintPrice(
      ethers.utils.parseUnits('0.0001', 18),
    );
    await changeMintPrice.wait();

    expect(await plushGetCoreToken.getMintPrice()).to.eql(
      ethers.utils.parseUnits('0.0001', 18),
    );
  });

  it('PlushGetCoreToken -> Change safe address', async () => {
    const changeSafeAddress = await plushGetCoreToken.setSafeAddress(
      plushGetCoreTokenRandomSafeAddress.address,
    );
    await changeSafeAddress.wait();

    expect(await plushGetCoreToken.getSafeAddress()).to.eql(
      plushGetCoreTokenRandomSafeAddress.address,
    );
  });

  it('PlushGetCoreToken -> Check minting', async () => {
    const mintToken = await plushGetCoreToken.mint(
      await signers[0].getAddress(),
      { value: ethers.utils.parseUnits('0.0001', 18) },
    );
    await mintToken.wait();

    expect(
      await plushCoreToken.balanceOf(await signers[0].getAddress()),
    ).to.eql(constants.One);

    const provider = new ethers.providers.JsonRpcProvider(rpc);

    const withdrawTokens = await plushGetCoreToken.withdraw(
      ethers.utils.parseUnits('0.0001', 18),
    );

    await withdrawTokens.wait();

    const getNewSafeBalance = await provider
      .getBalance(plushGetCoreTokenRandomSafeAddress.address)
      .then((balance) => {
        return ethers.utils.formatEther(balance);
      });

    expect(getNewSafeBalance).to.eql('0.0001');
  });

  it('PlushGetCoreToken -> Check pause contract', async () => {
    const pauseContract = await plushGetCoreToken.pause();
    await pauseContract.wait();
    expect(await plushGetCoreToken.paused()).to.eql(true);
    const onpauseContract = await plushGetCoreToken.unpause();
    await onpauseContract.wait();
  });

  it('PlushGetCoreToken -> Check upgrade contract', async () => {
    const plushGetCoreTokenNEW = (await upgrades.upgradeProxy(
      plushGetCoreToken.address,
      PlushGetCoreTokenFactory,
      { kind: 'uups' },
    )) as PlushGetCoreToken;
    await plushGetCoreTokenNEW.deployed();
    expect(plushGetCoreTokenNEW.address).to.eq(plushGetCoreToken.address);
    expect(await plushCoreToken.totalSupply()).to.eql(constants.Two);
  });

  it('PlushApps -> Checking role assignments', async () => {
    expect(
      await plushApps.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushApps.hasRole(
        '0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929',
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // OPERATOR role
    expect(
      await plushApps.hasRole(
        '0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a',
        await signers[0].getAddress(), // PAUSER role
      ),
    ).to.eql(true);
    expect(
      await plushApps.hasRole(
        '0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3',
        await signers[0].getAddress(), // UPGRADER role
      ),
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
      await plushFaucet.hasRole(
        '0x97667070c54ef182b0f5858b034beac1b6f3089aa2d3188bb1e8929f4fa9b929',
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // OPERATOR role
    expect(
      await plushFaucet.hasRole(
        '0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a',
        await signers[0].getAddress(), // PAUSER role
      ),
    ).to.eql(true);
    expect(
      await plushFaucet.hasRole(
        '0x189ab7a9244df0848122154315af71fe140f3db0fe014031783b0946b8c9d2e3',
        await signers[0].getAddress(), // UPGRADER role
      ),
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
      ethers.utils.parseUnits('2', 18),
    );
    await setApprove.wait();

    const transferTokens = await plushToken.transfer(
      plushFaucet.address,
      ethers.utils.parseUnits('2', 18),
    );
    await transferTokens.wait();

    expect(await plushFaucet.getFaucetBalance()).to.eql(
      ethers.utils.parseUnits('2', 18),
    );
  });

  it('PlushFaucet -> Get tokens from faucet to PlushCoinWallets', async () => {
    expect(
      await plushFaucet.getCanTheAddressReceiveReward(
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // Check that we can to get tokens

    const getTokens = await plushFaucet.send(await signers[0].getAddress());
    await getTokens.wait();

    expect(await plushFaucet.getFaucetBalance()).to.eql(
      ethers.utils.parseUnits('1', 18),
    );

    expect(
      await plushCoinWallets.getWalletAmount(await signers[0].getAddress()),
    ).to.eql(ethers.utils.parseUnits('1', 18)); // Check that we to get one token on Safe contract
  });

  it('PlushFaucet -> Check that we cant to get tokens twice', async () => {
    await expect(
      plushFaucet.getCanTheAddressReceiveReward(await signers[0].getAddress()),
    ).to.be.revertedWith('Time limit');
  });
});
