export enum DevContractsAddresses {
  PLUSH_COIN_ADDRESS = '0x6FB60c408363636dAC206AA98EE429d79923DD33', // ERC-20 Proxy contract
  PLUSH_COIN_IMPLEMENTATION_ADDRESS = '0x9A8de45Efe22637dc45DaFdDF211D1A4cfcb6ED7', // ERC-20 implementation contract. Use only for upgrade!
  WRAPPED_PLUSH_COIN_ADDRESS = '0x30f0ED21f6659890d498715b74e075E2C0C4A456', // Wrapped Plush Coin (ERC-20) contract
  PLUSH_FAUCET_ADDRESS = '0x3A17f8e4E349c2d604F5a26c07367D4015AC3e6d', // Plush Coin (ERC-20) contract faucet
  PLUSH_NFT_CASHBACK_POOL_ADDRESS = '0xCCD73369Df02bbe807A37B72A2740EE894c920Ce', // Plush NFT cashback pool contract
  LIFESPAN_ADDRESS = '0xEf5c7517C4c3cc09b6eFC12Aa183AF161A61A247', // ERC-721 LifeSpan contract
  PLUSH_GET_LIFESPAN_ADDRESS = '0x68F2A8d09393EFD5F2584C384c327DD7682ccB85', // Self-minting of ERC-721 LifeSpan token contract
  PLUSH_ACCOUNTS_ADDRESS = '0x8b99563c11653103205843d7CdDE598f8062947C', // Safe contract
  PLUSH_APPS_ADDRESS = '0x73F0829C079E6C369b02d17d51E1e11D53DB55aC', // Ecosystem contract
  PLUSH_FEE_COLLECTOR_ADDRESS = '0x108dEc7b37C526B2e2DBf8447573dDCB9265C884', // Plush Fee collector DAO contract (multisig)
  PLUSH_DAO_PROTOCOL_ADDRESS = '0xBB8Fe52cAA5F35Ec1475ac2ac6f1A273D67E2a10', // Plush DAO Protocol contract (multisig)
  PLUSH_SEED = '0x6e03DC94cCb78645856E06aE461fe3E4Dec98F9a', // ERC-721 PlushSeed contract
  PLUSH_AMBASSADOR = '0x0BCa3e41579FdCF6bFB9E7e57d4AD63B72b04c53', // ERC-1155 PlushAmbassador contract
  PLUSH_BLACKLIST = '0x480f2A4EA01b4444dEEB3bCe9d9934202cA5dc47', // Blacklist addresses contract
}

export enum DevLinks {
  PLUSH_LIFESPAN_LINK = 'https://home.plush.dev/token/', // Link to page with LifeSpan
  PLUSH_GENERATOR_IMG_LIFESPAN_LINK = 'https://api.plush.dev/user/tokens/render', // Link to page with generator image LifeSpan
}
