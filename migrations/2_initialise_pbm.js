module.exports = async ({getNamedAccounts, deployments, ethers}) => {
  const {deployer} = await getNamedAccounts();
  const deployerSigner = ethers.provider.getSigner(deployer);

  const spotDeployment = await deployments.get('Spot');
  const pbmDeployment = await deployments.get('PBM');
  const pbm = (await ethers.getContractFactory('PBM')).attach(pbmDeployment.address).connect(deployerSigner);

  const currentDate = new Date();
  const currentEpoch = Math.floor(currentDate / 1000);
  // Polygon XSGD address = 0xDC3326e71D45186F113a2F448984CA0e8D201995 ;
  await pbm.initialise(spotDeployment.address, currentEpoch + 200000); // contract expiry is set to 2 days and 7 hours from now for testing
}