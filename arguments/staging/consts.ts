export enum StageContractsAddresses {
  PLUSH_COIN_ADDRESS = '0xA9FD53c86f30534A39392e1dADfb5C078f241C94', // ERC-20 Proxy contract
  PLUSH_COIN_IMPLEMENTATION_ADDRESS = '0xF9C4A16Dc71d98dFa0D6E8321E8d02166ac7947B', // ERC-20 implementation contract. Use only for upgrade!
  WRAPPED_PLUSH_COIN_ADDRESS = '0xD3B1367595804F2EB5dB478c8B6ee08Bb6810272', // Wrapped Plush Coin (ERC-20) contract
  PLUSH_FAUCET_ADDRESS = '0x9d4D8481937B963C64ea9E6a67B08dE488f5F485', // Plush Coin (ERC-20) contract faucet
  PLUSH_NFT_CASHBACK_POOL_ADDRESS = '0xc03004DB0F35feE00Ac22fEe3aE2a08583ab548c', // Plush NFT cashback pool contract
  LIFESPAN_ADDRESS = '0x330a2BaaCEcF4d89f0f65c05c6928cF74523C110', // ERC-721 LifeSpan contract
  PLUSH_GET_LIFESPAN_ADDRESS = '0xC3C990dd6465cc2B1006f4985d47fd57CBf6A6A5', // Self-minting of ERC-721 LifeSpan token contract
  PLUSH_ACCOUNTS_ADDRESS = '0x580C3fAf8b48d66a7c9be2Ce5ddEa0e5262f2e3B', // Safe contract
  PLUSH_APPS_ADDRESS = '0x9e953f56C94C25622E483a14341A0799ea1ee967', // Ecosystem contract
  PLUSH_FEE_COLLECTOR_ADDRESS = '0x8E816Acb4E93DFe8f89195169ebDD4E1Ba7d3a20', // Plush Fee collector DAO contract (multisig)
  PLUSH_DAO_PROTOCOL_ADDRESS = '0xca044999dF0c67923f5cCF3DCb8DFDFf72ADA86f', // Plush DAO Protocol contract (multisig)
  PLUSH_SEED = '0x6e03DC94cCb78645856E06aE461fe3E4Dec98F9a', // ERC-721 PlushSeed contract
  PLUSH_SEED_TOKENS_KEEPER = '0x07E2383EF2eB15C3C3c6C2b29121FCCcA2AFcb48', // Address where all ERC721 PlushSeed tokens are stored
}

export enum DevLinks {
  PLUSH_LIFESPAN_LINK = 'https://home.plush.family/token/', // Link to page with LifeSpan
  PLUSH_GENERATOR_IMG_LIFESPAN_LINK = 'ipfs://QmVVsfk8n8KdNeo5wAFCweDsoWMCLhqfYtbgdVXt8y2JhA', // Link to page with generator image LifeSpan
}
