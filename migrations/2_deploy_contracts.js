const RealEstateNFT = artifacts.require('./RealEstateNFT.sol')

module.exports = function (deployer) {
  deployer.deploy(RealEstateNFT)
}
