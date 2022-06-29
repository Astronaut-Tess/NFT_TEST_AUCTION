const NFTItem1155 = artifacts.require("NFTItem1155");

module.exports = async function (deployer2, network, accounts) {
  await deployer2.deploy(NFTItem1155);
};
