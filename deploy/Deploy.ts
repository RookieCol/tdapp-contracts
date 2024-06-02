import { DeployFunction } from "hardhat-deploy/types"
import { HardhatRuntimeEnvironment } from "hardhat/types"

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
	const { deployer } = await hre.getNamedAccounts()
	const { deployments, ethers } = hre
	const { deploy } = deployments

	const deploymentResult = await deploy("TelegramAdPlatform", {
		from: deployer,
		args: [deployer], // Asegúrate de que esto coincida con el constructor del contrato
		log: true,
	})

	// Log the deployment details
	console.log("TelegramAdPlatform deployed to:", deploymentResult.address)
	console.log("Deployed by:", deployer)
}

export default func
