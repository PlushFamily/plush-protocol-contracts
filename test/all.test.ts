import { expect } from 'chai';
import { BigNumber, constants, ContractFactory, Signer } from 'ethers';
import { ethers, upgrades, waffle } from 'hardhat';

import {
  LifeSpan,
  Plush,
  PlushAccounts,
  PlushAmbassador,
  PlushApps,
  PlushBlacklist,
  PlushController,
  PlushFaucet,
  PlushGetAmbassador,
  PlushGetLifeSpan,
  PlushLifeSpanNFTCashbackPool,
  WrappedPlush,
} from '../types';
import { DevLinks } from '../arguments/development/consts';

const BANKER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('BANKER_ROLE'),
);
const OPERATOR_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('OPERATOR_ROLE'),
);
const STAFF_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('STAFF_ROLE'),
);
const REMUNERATION_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('REMUNERATION_ROLE'),
);
const MINTER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('MINTER_ROLE'),
);
const URI_SETTER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('URI_SETTER_ROLE'),
);
const PAUSER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('PAUSER_ROLE'),
);
const UPGRADER_ROLE = ethers.utils.keccak256(
  ethers.utils.toUtf8Bytes('UPGRADER_ROLE'),
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

  let PlushBlacklistFactory: ContractFactory;
  let plushBlacklist: PlushBlacklist;

  let PlushGetLifeSpanFactory: ContractFactory;
  let plushGetLifeSpan: PlushGetLifeSpan;
  const plushGetLifeSpanRandomSafeAddress = ethers.Wallet.createRandom();

  let PlushLifeSpanNFTCashbackPoolFactory: ContractFactory;
  let plushLifeSpanNFTCashbackPool: PlushLifeSpanNFTCashbackPool;

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

  let PlushAmbassadorFactory: ContractFactory;
  let plushAmbassador: PlushAmbassador;

  let PlushGetAmbassadorFactory: ContractFactory;
  let plushGetAmbassador: PlushGetAmbassador;

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
    lifeSpan = (await upgrades.deployProxy(
      LifeSpanFactory,
      [
        DevLinks.PLUSH_LIFESPAN_LINK,
        DevLinks.PLUSH_GENERATOR_IMG_LIFESPAN_LINK,
      ],
      {
        kind: 'uups',
      },
    )) as LifeSpan;
    await lifeSpan.deployed();
  });

  it('[Deploy contract] PlushBlacklist', async () => {
    PlushBlacklistFactory = await ethers.getContractFactory('PlushBlacklist');
    plushBlacklist = (await upgrades.deployProxy(PlushBlacklistFactory, {
      kind: 'uups',
    })) as PlushBlacklist;
    await plushBlacklist.deployed();
  });

  it('[Deploy contract] PlushLifeSpanNFTCashbackPool', async () => {
    PlushLifeSpanNFTCashbackPoolFactory = await ethers.getContractFactory(
      'PlushLifeSpanNFTCashbackPool',
    );
    plushLifeSpanNFTCashbackPool = (await upgrades.deployProxy(
      PlushLifeSpanNFTCashbackPoolFactory,
      [
        plushToken.address,
        plushBlacklist.address,
        1000000000000, // remuneration amount (in wei!)
        120, // time after which tokens will be unlocked (in sec!)
      ],
      {
        kind: 'uups',
      },
    )) as PlushLifeSpanNFTCashbackPool;
    await plushLifeSpanNFTCashbackPool.deployed();
  });

  it('[Deploy contract] PlushGetLifeSpan', async () => {
    PlushGetLifeSpanFactory = await ethers.getContractFactory(
      'PlushGetLifeSpan',
    );
    plushGetLifeSpan = (await upgrades.deployProxy(
      PlushGetLifeSpanFactory,
      [
        lifeSpan.address,
        plushBlacklist.address,
        await signers[1].getAddress(),
        ethers.utils.parseUnits('0.001', 18),
      ],
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

  it('[Deploy contract] PlushAmbassador', async () => {
    PlushAmbassadorFactory = await ethers.getContractFactory('PlushAmbassador');
    plushAmbassador = (await upgrades.deployProxy(
      PlushAmbassadorFactory,
      [
        'Plush Ambassador',
        'PLAM',
        'ipfs://QmYBiofrRjAKGxZg4518osmkzrQS24aQgZ4CKC6RyV9DDi/{id}',
        'ipfs://QmXTTH1CTkNTJe6T7NiFfQRSaUwMiKHxcbeLKJyp9WdHgz',
      ],
      {
        kind: 'uups',
      },
    )) as PlushAmbassador;
    await plushAmbassador.deployed();
  });

  it('[Deploy contract] PlushGetAmbassador', async () => {
    PlushGetAmbassadorFactory = await ethers.getContractFactory(
      'PlushGetAmbassador',
    );
    plushGetAmbassador = (await upgrades.deployProxy(
      PlushGetAmbassadorFactory,
      [plushAmbassador.address],
      {
        kind: 'uups',
      },
    )) as PlushGetAmbassador;
    await plushGetAmbassador.deployed();
  });

  it('Plush -> Check total supply', async () => {
    expect(await plushToken.totalSupply()).to.deep.equal(
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
    expect(
      await plushToken.balanceOf(await signers[1].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('1', 18)); // Checking the sending of tokens
  });

  it('Plush -> Check burning tokens', async () => {
    const burnTokens = await plushToken.burn(ethers.utils.parseUnits('1', 18));
    await burnTokens.wait();
    expect(
      await plushToken.balanceOf(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('9999999998', 18)); // Checking the burning of a single token
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
    ).to.deep.equal(ethers.utils.parseUnits('1', 18)); // Checking the setting of the permission to spend tokens for another address
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
    expect(
      await plushToken.balanceOf(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('9999999997', 18)); // Checking the spending of tokens after setting the permission to spend funds
  });

  it('WrappedPlush -> Check Plush address', async () => {
    expect(await wrappedPlush.underlying()).to.eql(plushToken.address);
    // Checking that the connection between the contracts has been established
  });

  it('WrappedPlush -> Check total supply', async () => {
    expect(await wrappedPlush.totalSupply()).to.deep.equal(
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

    expect(
      await wrappedPlush.balanceOf(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('3', 18)); // Checking that user has 3 wrapped tokens.

    expect(
      await plushToken.balanceOf(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('9999999994', 18)); // Checking that the number of Plush tokens has decreased
  });

  it('WrappedPlush -> Check unwrapping', async () => {
    const unwrappingTokens = await wrappedPlush.withdrawTo(
      await signers[0].getAddress(),
      ethers.utils.parseUnits('1', 18),
    );
    await unwrappingTokens.wait();

    expect(
      await plushToken.balanceOf(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('9999999995', 18));
    expect(
      await wrappedPlush.balanceOf(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('2', 18));
  });

  it('WrappedPlush -> Check burning', async () => {
    const burningTokens = await wrappedPlush.burn(
      ethers.utils.parseUnits('1', 18),
    );
    await burningTokens.wait();

    expect(
      await wrappedPlush.balanceOf(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('1', 18));
  });

  it('WrappedPlush -> Check delegate', async () => {
    const depositTokens = await wrappedPlush.delegate(
      await signers[1].getAddress(),
    );
    await depositTokens.wait();

    // add checks after delegate
  });

  it('LifeSpan -> Add genders', async () => {
    const male = await lifeSpan.addGender(0, 'MALE'); // MALE gender
    await male.wait();

    const female = await lifeSpan.addGender(1, 'FEMALE'); // FEMALE gender
    await female.wait();
  });

  it('LifeSpan -> Check total supply', async () => {
    expect(await lifeSpan.totalSupply()).to.deep.equal(ethers.constants.Zero); // ADMIN role
  });

  it('LifeSpan -> Checking role assignments', async () => {
    expect(
      await lifeSpan.hasRole(constants.HashZero, await signers[0].getAddress()),
    ).to.deep.equal(true); // ADMIN role
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
      .safeMint(await signers[1].getAddress(), 'Tester', 0, 918606632);
    await mintToken.wait();
    expect(
      await lifeSpan.balanceOf(await signers[1].getAddress()),
    ).to.deep.equal(constants.One);

    const tokenData = await lifeSpan.tokenData(0);

    expect(tokenData.name).to.deep.equal('Tester');
    expect(tokenData.gender).to.deep.equal('0');
    expect(tokenData.birthdayDate).to.deep.equal('918606632');
  });

  it('LifeSpan -> Validate function tokenURI response', async () => {
    const tokenURIResp = await lifeSpan.tokenURI(0);
    const tokenURIRespDecode = JSON.parse(
      Buffer.from(tokenURIResp.split(',')[1], 'base64').toString('utf-8'),
    );

    expect(tokenURIRespDecode.description).to.deep.equal(
      'Plush ecosystem avatar',
    );
    expect(tokenURIRespDecode.external_url).to.deep.equal(
      'https://home.plush.dev/token/0',
    );
    expect(tokenURIRespDecode.name).to.deep.equal("Tester's Plush Token");
    expect(tokenURIRespDecode.image).to.deep.equal(
      'https://api.plush.dev/user/tokens/render?birthdayDate=918606632&name=Tester&gender=0',
    );
    expect(tokenURIRespDecode.attributes[0].display_type).to.deep.equal('date');
    expect(tokenURIRespDecode.attributes[0].trait_type).to.deep.equal(
      'Birthday',
    );
    expect(tokenURIRespDecode.attributes[0]).to.deep.equal({
      display_type: 'date',
      trait_type: 'Birthday',
      value: 918606632,
    });

    expect(tokenURIRespDecode.attributes[1]).to.deep.include({
      display_type: 'date',
      trait_type: 'Date of Mint',
    });

    expect(tokenURIRespDecode.attributes[2]).to.deep.equal({
      trait_type: 'Gender',
      value: 'MALE',
    });
  });

  it('LifeSpan -> Check changing token name', async () => {
    await expect(lifeSpan.updateTokenName(0, 'Plush Tester')).to.be.reverted; // don't a token owner

    const changeName = await lifeSpan
      .connect(signers[1])
      .updateTokenName(0, 'Plush Tester');

    await changeName.wait();

    const tokenData = await lifeSpan.tokenData(0);

    expect(tokenData.name).to.deep.equal('Plush Tester');
  });

  it('LifeSpan -> Check changing token gender', async () => {
    await expect(lifeSpan.updateTokenGender(0, 1)).to.be.reverted; // don't a token owner

    await expect(lifeSpan.connect(signers[1]).updateTokenGender(0, 2)).to.be
      .reverted; // gender doesn't exists

    const changeGender = await lifeSpan
      .connect(signers[1])
      .updateTokenGender(0, 1);

    await changeGender.wait();

    const tokenData = await lifeSpan.tokenData(0);

    expect(tokenData.gender).to.deep.equal('1');
  });

  it('LifeSpan -> Check adding new gender', async () => {
    await expect(lifeSpan.addGender(0, 'MALE')).to.be.reverted; // gender already exists

    const addGender = await lifeSpan.addGender(2, 'TEST');
    await addGender.wait();
  });

  it('LifeSpan -> Check update external URL', async () => {
    await expect(
      lifeSpan.connect(signers[1]).updateExternalURL('https://test.com/token/'),
    ).to.be.reverted; // don't have rights

    const updateExternalURL = await lifeSpan.updateExternalURL(
      'https://test.com/token/',
    );
    await updateExternalURL.wait();
  });

  it('LifeSpan -> Check update render URL', async () => {
    await expect(
      lifeSpan
        .connect(signers[1])
        .updateRenderImageURL('https://test.com/token/'),
    ).to.be.reverted; // don't have rights

    const updateRenderURL = await lifeSpan.updateRenderImageURL(
      'https://test.com/token/',
    );
    await updateRenderURL.wait();
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
    expect(await lifeSpan.totalSupply()).to.deep.equal(constants.One);
  });

  it('PlushGetLifeSpan -> Checking role assignments', async () => {
    expect(
      await plushGetLifeSpan.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushGetLifeSpan.hasRole(
        BANKER_ROLE,
        await signers[0].getAddress(),
      ),
    ).to.eql(true);
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

  it('PlushGetLifeSpan -> Grant operator role in PlushLifeSpanNFTCashbackPool contract', async () => {
    const grantRole = await plushLifeSpanNFTCashbackPool.grantRole(
      OPERATOR_ROLE,
      plushGetLifeSpan.address,
    );
    await grantRole.wait();
    expect(
      await plushLifeSpanNFTCashbackPool.hasRole(
        OPERATOR_ROLE,
        plushGetLifeSpan.address,
      ),
    ).to.eql(true);
  });

  it('PlushGetLifeSpan -> Grant REMUNERATION_ROLE in PlushLifeSpanNFTCashbackPool contract', async () => {
    const grantRole = await plushLifeSpanNFTCashbackPool.grantRole(
      REMUNERATION_ROLE,
      plushGetLifeSpan.address,
    );
    await grantRole.wait();
    expect(
      await plushLifeSpanNFTCashbackPool.hasRole(
        REMUNERATION_ROLE,
        plushGetLifeSpan.address,
      ),
    ).to.eql(true);
  });

  it('PlushGetLifeSpan -> Check safe address', async () => {
    expect(await plushGetLifeSpan.feeAddress()).to.eql(
      await signers[1].getAddress(),
    );
  });

  it('PlushGetLifeSpan -> Check mint price', async () => {
    expect(await plushGetLifeSpan.mintPrice()).to.deep.equal(
      ethers.utils.parseUnits('0.001', 18),
    );
  });

  it('PlushGetLifeSpan -> Change mint price', async () => {
    const changeMintPrice = await plushGetLifeSpan.changeMintPrice(
      ethers.utils.parseUnits('0.0001', 18),
    );
    await changeMintPrice.wait();

    expect(await plushGetLifeSpan.mintPrice()).to.deep.equal(
      ethers.utils.parseUnits('0.0001', 18),
    );
  });

  it('PlushGetLifeSpan -> Change safe address', async () => {
    const changeSafeAddress = await plushGetLifeSpan.setFeeAddress(
      plushGetLifeSpanRandomSafeAddress.address,
    );
    await changeSafeAddress.wait();

    expect(await plushGetLifeSpan.feeAddress()).to.eql(
      plushGetLifeSpanRandomSafeAddress.address,
    );
  });

  it('PlushGetLifeSpan -> Check minting', async () => {
    const mintToken = await plushGetLifeSpan.mint(
      await signers[0].getAddress(),
      'John',
      0,
      918606632,
      { value: ethers.utils.parseEther('0.0001') },
    );
    await mintToken.wait();

    const tokenData = await lifeSpan.tokenData(1);

    expect(tokenData.name).to.deep.equal('John');
    expect(tokenData.gender).to.deep.equal('0');
    expect(tokenData.birthdayDate).to.deep.equal('918606632');

    expect(
      await lifeSpan.balanceOf(await signers[0].getAddress()),
    ).to.deep.equal(constants.One);

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

    const getMintContractBalance = await provider
      .getBalance(plushGetLifeSpan.address)
      .then((balance) => {
        return ethers.utils.formatEther(balance);
      });

    expect(getMintContractBalance).to.eql('0.0');
    expect(getNewSafeBalance).to.eql('0.0001');
  });

  it('PlushGetLifeSpan -> Check free minting', async () => {
    await expect(
      plushGetLifeSpan
        .connect(signers[1])
        .freeMint(await signers[1].getAddress(), 'Olivia', 1, 1079051432),
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
      .freeMint(randomAddress.address, 'Olivia', 1, 1079051432);
    await mintToken.wait();

    const tokenData = await lifeSpan.tokenData(2);

    expect(await lifeSpan.balanceOf(randomAddress.address)).to.deep.equal(
      constants.One,
    );

    expect(tokenData.name).to.deep.equal('Olivia');
    expect(tokenData.gender).to.deep.equal('1');
    expect(tokenData.birthdayDate).to.deep.equal('1079051432');
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
    expect(await lifeSpan.totalSupply()).to.deep.equal(BigNumber.from('3'));
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
    const testApp = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('test'));

    const addApp = await plushApps.addNewApp(
      testApp,
      plushController.address,
      '50',
    );
    await addApp.wait();

    expect(await plushApps.getFeeApp(plushController.address)).to.deep.equal(
      BigNumber.from('50'),
    );
  });

  it('PlushApps -> Change fee app', async () => {
    const changingFee = await plushApps.setFeeApp(
      plushController.address,
      '100',
    );
    await changingFee.wait();

    expect(await plushApps.getFeeApp(plushController.address)).to.deep.equal(
      BigNumber.from('100'),
    );
  });

  it('PlushApps -> Test disable app', async () => {
    const disableApp = await plushApps.setAppDisable(plushController.address);
    await disableApp.wait();

    expect(await plushApps.getAppStatus(plushController.address)).to.eql(false);

    // add test some activity with controller

    const enableApp = await plushApps.setAppEnable(plushController.address);
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
      await plushFaucet.hasRole(BANKER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await plushFaucet.hasRole(PAUSER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
    expect(
      await plushFaucet.hasRole(UPGRADER_ROLE, await signers[0].getAddress()),
    ).to.eql(true);
  });

  it('PlushFaucet -> Checking initial values', async () => {
    expect(await plushFaucet.getTimeLimit()).to.deep.equal(
      BigNumber.from('86400'),
    ); // 24 hours

    expect(await plushFaucet.getFaucetDripAmount()).to.deep.equal(
      ethers.utils.parseUnits('1', 18),
    ); // 1 Plush

    expect(await plushFaucet.getMaxReceiveAmount()).to.deep.equal(
      ethers.utils.parseUnits('100', 18),
    ); // Max Plush user balance

    expect(await plushFaucet.getIsTokenNFTCheck()).to.eql(true); // NFT check

    expect(await plushFaucet.getFaucetBalance()).to.deep.equal(
      ethers.constants.Zero,
    ); // Check Faucet balance
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

    expect(await plushFaucet.getFaucetBalance()).to.deep.equal(
      ethers.utils.parseUnits('3', 18),
    );
  });

  it('PlushFaucet -> Get tokens from faucet to PlushAccounts', async () => {
    expect(
      await plushFaucet.getCanTheAddressReceiveReward(
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // Check that we can to get tokens

    const getTokens = await plushFaucet.send();
    await getTokens.wait();

    expect(await plushFaucet.getFaucetBalance()).to.deep.equal(
      ethers.utils.parseUnits('2', 18),
    );
    expect(
      await plushAccounts.getAccountBalance(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('1', 18)); // Check that we to get one token on Safe contract
  });

  it("PlushFaucet -> Check that we can't to get tokens twice", async () => {
    await expect(
      plushFaucet.getCanTheAddressReceiveReward(await signers[0].getAddress()),
    ).to.be.reverted;
  });

  it('PlushFaucet -> Set disable NFT checking', async () => {
    const changeNFTCheck = await plushFaucet.setDisableNFTCheck();
    await changeNFTCheck.wait();
    expect(await plushFaucet.getIsTokenNFTCheck()).to.eql(false);
  });

  it('PlushFaucet -> Try to get tokens without NFT (with disable NFT checking)', async () => {
    const getTokens = await plushFaucet.connect(signers[1]).send();
    await getTokens.wait();
    expect(
      await plushAccounts.getAccountBalance(await signers[1].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('1', 18));
    await expect(
      plushFaucet.getCanTheAddressReceiveReward(await signers[1].getAddress()),
    ).to.be.reverted;
  });

  it('PlushFaucet -> Withdraw tokens from faucet', async () => {
    const withdrawTokens = await plushFaucet.withdraw(
      ethers.utils.parseUnits('1', 18),
      plushFaucetRandomReceiverAddress.address,
    );
    await withdrawTokens.wait();

    expect(
      await plushToken.balanceOf(plushFaucetRandomReceiverAddress.address),
    ).to.deep.equal(ethers.utils.parseUnits('1', 18));
    expect(await plushFaucet.getFaucetBalance()).to.deep.equal(
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
    expect(await plushAccounts.getPlushFeeAddress()).to.eql(
      plushAccountsRandomSafeAddress.address,
    );
  });

  it('PlushAccounts -> Check user balances', async () => {
    expect(
      await plushAccounts.getAccountBalance(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('1', 18));
  });

  it('PlushAccounts -> Check transfer tokens inside safe', async () => {
    const transferTokens = await plushAccounts.internalTransfer(
      await signers[1].getAddress(),
      ethers.utils.parseUnits('1', 18),
    );
    await transferTokens.wait();
    expect(
      await plushAccounts.getAccountBalance(await signers[0].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('0', 18));
    expect(
      await plushAccounts.getAccountBalance(await signers[1].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('2', 18));
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
      await plushAccounts.getAccountBalance(await signers[1].getAddress()),
    ).to.deep.equal(ethers.utils.parseUnits('2', 18));
  });

  it('PlushAmbassador -> Checking role assignments', async () => {
    expect(
      await plushAmbassador.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushAmbassador.hasRole(
        URI_SETTER_ROLE,
        await signers[0].getAddress(),
      ),
    ).to.eql(true);
    expect(
      await plushAmbassador.hasRole(
        UPGRADER_ROLE,
        await signers[0].getAddress(),
      ),
    ).to.eql(true);
  });

  it('PlushAmbassador -> Check init supply', async () => {
    expect(await plushAmbassador.exists(constants.Zero)).to.eql(false);
  });

  it('PlushAmbassador -> Check name, ticker and URI', async () => {
    expect(await plushAmbassador.name()).to.eql('Plush Ambassador');
    expect(await plushAmbassador.symbol()).to.eql('PLAM');
    expect(await plushAmbassador.uri(constants.Zero)).to.eql(
      'ipfs://QmYBiofrRjAKGxZg4518osmkzrQS24aQgZ4CKC6RyV9DDi/{id}',
    );
    expect(await plushAmbassador.contractURI()).to.eql(
      'ipfs://QmXTTH1CTkNTJe6T7NiFfQRSaUwMiKHxcbeLKJyp9WdHgz',
    );
  });

  it('PlushAmbassador -> Grant OPERATOR_ROLE in PlushGetAmbassador contract', async () => {
    const grantRole = await plushAmbassador.grantRole(
      MINTER_ROLE,
      plushGetAmbassador.address,
    );
    await grantRole.wait();
    expect(
      await plushAmbassador.hasRole(MINTER_ROLE, plushGetAmbassador.address),
    ).to.eql(true);
  });

  it('PlushGetAmbassador -> Checking role assignments', async () => {
    expect(
      await plushGetAmbassador.hasRole(
        constants.HashZero,
        await signers[0].getAddress(),
      ),
    ).to.eql(true); // ADMIN role
    expect(
      await plushGetAmbassador.hasRole(
        OPERATOR_ROLE,
        await signers[0].getAddress(),
      ),
    ).to.eql(true);
    expect(
      await plushGetAmbassador.hasRole(
        UPGRADER_ROLE,
        await signers[0].getAddress(),
      ),
    ).to.eql(true);
  });

  it('PlushGetAmbassador -> Add new token', async () => {
    const addNewToken = await plushGetAmbassador.addNewToken(constants.One);
    await addNewToken.wait();

    const tokenData = await plushGetAmbassador.tokens(constants.One);
    expect(tokenData.id).to.deep.equal('1');
    expect(tokenData.active).to.deep.equal(true);
    expect(tokenData.exists).to.deep.equal(true);
  });

  it('PlushGetAmbassador -> Check that we cant mint new token', async () => {
    expect(
      await plushGetAmbassador.checkMintPossibility(
        await signers[0].getAddress(),
      ),
    ).to.eql(true);
  });

  it('PlushGetAmbassador -> Check minting token', async () => {
    const mintToken = await plushGetAmbassador.mint(constants.One);
    await mintToken.wait();

    expect(
      await plushGetAmbassador.applicants(await signers[0].getAddress()),
    ).to.eql(true);

    expect(
      await plushAmbassador.balanceOf(
        await signers[0].getAddress(),
        constants.One,
      ),
    ).to.eql(constants.One);
  });

  it("PlushGetAmbassador -> Try that we cant't to mint twice", async () => {
    await expect(plushGetAmbassador.mint(constants.One)).to.be.reverted;
  });
});
