export enum DevContractsAddresses {
  PLUSH_COIN_ADDRESS = '0x6FB60c408363636dAC206AA98EE429d79923DD33', // ERC-20 Proxy contract
  PLUSH_COIN_IMPLEMENTATION_ADDRESS = '0x9A8de45Efe22637dc45DaFdDF211D1A4cfcb6ED7', // ERC-20 implementation contract. Use only for upgrade!
  WRAPPED_PLUSH_COIN_ADDRESS = '0x0D676186A942e61EDF5FE3a6Dfdcd4c9a7239000', // Wrapped Plush Coin (ERC-20) contract
  PLUSH_FAUCET_ADDRESS = '0x1ec3eF4d8c44334DFa1214721A7C9a7660679710', // Plush Coin (ERC-20) contract faucet
  PLUSH_NFT_CASHBACK_POOL_ADDRESS = '0xC5e60E7a50EA4a15Da57214884dB3d74fa6442EE', // Plush NFT cashback pool contract
  LIFESPAN_ADDRESS = '0xF223230144547aB2541ffA092338dBD2C9A59C34', // ERC-721 LifeSpan contract
  PLUSH_GET_LIFESPAN_ADDRESS = '0x31221c59829206042F2970e14e99714C969E33F3', // Self-minting of ERC-721 LifeSpan token contract
  PLUSH_ACCOUNTS_ADDRESS = '0xADb915E0dEf2D5B9F3f3FA2dcB8E0de774573D8B', // Safe contract
  PLUSH_APPS_ADDRESS = '0x0942070631E0A837BA92299A73Ad340c09e9fd9d', // Ecosystem contract
  PLUSH_FEE_COLLECTOR_ADDRESS = '0x108dEc7b37C526B2e2DBf8447573dDCB9265C884', // Plush Fee collector DAO contract (multisig)
  PLUSH_DAO_PROTOCOL_ADDRESS = '0xBB8Fe52cAA5F35Ec1475ac2ac6f1A273D67E2a10', // Plush DAO Protocol contract (multisig)
  PLUSH_SEED = '0x6e03DC94cCb78645856E06aE461fe3E4Dec98F9a', // ERC-721 PlushSeed contract
}

export enum DevLinks {
  PLUSH_LIFESPAN_LINK = 'https://home.plush.dev/token/', // Link to page with LifeSpan
  PLUSH_GENERATOR_IMG_LIFESPAN_LINK = 'https://api.plush.dev/user/tokens/render', // Link to page with generator image LifeSpan
}
