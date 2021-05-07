module.exports = {
  compilers: {
    solc: {
      version: '^0.8.0',
    },
  },
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },
    teams: {
        url: "https://sandbox.truffleteams.com/795a754b-ea8c-43f7-9278-385581ba340a",
      network_id: "1620083791470"
    }
  }
};
