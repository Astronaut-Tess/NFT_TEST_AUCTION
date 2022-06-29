const ImgMarketplace = artifacts.require("ImgMarketplace");

module.exports = async function (deployer2, network, accounts) {
  await deployer2.deploy(ImgMarketplace);
};
