import { DevContractsAddresses as dev } from './development/consts';

interface IGetContractAddress {
  environment: 'development';
  contract:
    | 'PLUSH_COIN_ADDRESS'
    | 'PLUSH_COIN_IMPLEMENTATION_ADDRESS'
    | 'WRAPPED_PLUSH_COIN_ADDRESS'
    | 'PLUSH_FAUCET_ADDRESS'
    | 'LIFESPAN_ADDRESS'
    | 'PLUSH_GET_LIFESPAN_ADDRESS'
    | 'PLUSH_ACCOUNTS_ADDRESS'
    | 'PLUSH_APPS_ADDRESS'
    | 'PLUSH_FEE_COLLECTOR_ADDRESS'
    | 'PLUSH_DAO_PROTOCOL_ADDRESS';
}

export function getContractAddress(data: IGetContractAddress) {
  switch (data.environment) {
    case 'development':
      return dev[data.contract];
    default:
      throw new Error("The environment doesn't exist!");
  }
}
