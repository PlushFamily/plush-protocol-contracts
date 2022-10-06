export enum DevContractsAddresses {
  PLUSH_COIN_ADDRESS = '0x6FB60c408363636dAC206AA98EE429d79923DD33', // ERC-20 Proxy contract
  PLUSH_COIN_IMPLEMENTATION_ADDRESS = '0x9A8de45Efe22637dc45DaFdDF211D1A4cfcb6ED7', // ERC-20 implementation contract. Use only for upgrade!
  WRAPPED_PLUSH_COIN_ADDRESS = '0x30f0ED21f6659890d498715b74e075E2C0C4A456', // Wrapped Plush Coin (ERC-20) contract
  PLUSH_FAUCET_ADDRESS = '0x3A17f8e4E349c2d604F5a26c07367D4015AC3e6d', // Plush Coin (ERC-20) contract faucet
  PLUSH_NFT_CASHBACK_POOL_ADDRESS = '0xCCD73369Df02bbe807A37B72A2740EE894c920Ce', // Plush NFT cashback pool contract
  LIFESPAN_ADDRESS = '0x2cbf2F053e4B478D039655b2684DdA1F46bf11F5', // ERC-721 LifeSpan contract
  PLUSH_GET_LIFESPAN_ADDRESS = '0xd8C625b8f01D28B96cD4dc31150B96Ac92A7fe3F', // Self-minting of ERC-721 LifeSpan token contract
  PLUSH_ACCOUNTS_ADDRESS = '0x8b99563c11653103205843d7CdDE598f8062947C', // Safe contract
  PLUSH_APPS_ADDRESS = '0x73F0829C079E6C369b02d17d51E1e11D53DB55aC', // Ecosystem contract
  PLUSH_FEE_COLLECTOR_ADDRESS = '0xC54B26C13E09930935d20d537858d706Aa882615', // Plush Fee collector DAO contract (multisig)
  PLUSH_DAO_PROTOCOL_ADDRESS = '0xD8A160D27d2d4AFE6f70e97E286FB220F72Fb1Dd', // Plush DAO Protocol contract (multisig)
  PLUSH_SEED = '0x6e03DC94cCb78645856E06aE461fe3E4Dec98F9a', // ERC-721 PlushSeed contract
  PLUSH_AMBASSADOR = '0x47d2c874C9dB2a24eF0135Ae699BB1F71963269a', // ERC-1155 PlushAmbassador contract
  PLUSH_BLACKLIST = '0xc1c0c5D43ea3b034D8Ae91541a5db914394abe80', // Blacklist addresses contract
}

export enum DevLinks {
  PLUSH_LIFESPAN_EXTERNAL_LINK = 'https://lifespan.one/token/', // Link to page with LifeSpan
  PLUSH_GENERATOR_IMG_LIFESPAN_LINK = 'https://api.plush.dev/user/tokens/render', // Link to page with generator image LifeSpan
  PLUSH_LIFESPAN_CONTRACT_URI = 'ipfs://QmbvYczw9ZNt8WTXVor4qQNDZJWu4Sz6WXzaKn1YVC4eP3',
}
