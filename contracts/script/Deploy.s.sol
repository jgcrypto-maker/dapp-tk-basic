// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { TokenSale } from "../src/TokenSale.sol";

/// @notice Deploys a sale (which creates its own SaleToken) and writes the environment
///         deployment file: `deployments/<env>.json`.
/// @dev Defaults are the prototype launch case; override with environment variables
///      (TOTAL_SUPPLY, INVENTORY, PRICE_PER_TOKEN_WEI, DURATION_DAYS, ...).
contract Deploy is Script {
    function run() external returns (TokenSale sale) {
        address owner = vm.envOr("OWNER", msg.sender);
        uint256 supply = vm.envOr("TOTAL_SUPPLY", uint256(1_000_000e18));
        uint256 inventory = vm.envOr("INVENTORY", supply);
        uint64 start = uint64(vm.envOr("START_TIME", uint256(block.timestamp)));
        uint64 end = uint64(
            vm.envOr(
                "END_TIME",
                uint256(block.timestamp + vm.envOr("DURATION_DAYS", uint256(30)) * 1 days)
            )
        );

        TokenSale.SaleConfig memory config = TokenSale.SaleConfig({
            name: vm.envOr("TOKEN_NAME", string("Demo Token")),
            symbol: vm.envOr("TOKEN_SYMBOL", string("TK")),
            totalSupply: supply,
            inventory: inventory,
            treasury: vm.envOr("TREASURY", owner),
            pricePerTokenWei: vm.envOr("PRICE_PER_TOKEN_WEI", uint256(1e16)),
            startTime: start,
            endTime: end,
            minTokensPerPurchase: vm.envOr("MIN_TOKENS_PER_PURCHASE", uint256(1_000e18)),
            maxTokensPerWallet: vm.envOr("MAX_TOKENS_PER_WALLET", uint256(100_000e18)),
            owner: owner
        });

        vm.startBroadcast();
        sale = new TokenSale(config);
        vm.stopBroadcast();

        console.log("TokenSale: ", address(sale));
        console.log("SaleToken: ", address(sale.token()));
        console.log("Owner:     ", owner);

        string memory file = vm.envOr("DEPLOYMENT_FILE", string("../deployments/dev.json"));
        vm.writeFile(file, _deploymentJson(sale, owner));
    }

    function _deploymentJson(TokenSale sale, address owner) internal view returns (string memory) {
        return string.concat(
            "{\n  \"chainId\": ",
            vm.toString(block.chainid),
            ",\n  \"sales\": [\n    { \"id\": 1, \"sale\": \"",
            vm.toString(address(sale)),
            "\", \"token\": \"",
            vm.toString(address(sale.token())),
            "\", \"owner\": \"",
            vm.toString(owner),
            "\", \"deployBlock\": ",
            vm.toString(block.number),
            " }\n  ]\n}\n"
        );
    }
}
