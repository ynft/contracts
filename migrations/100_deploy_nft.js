const TestNft = artifacts.require('TestNft');



module.exports = async (deployer, network, accounts) => {
  await deployer.deploy(TestNft);
};
