// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Smoke } from "../src/Smoke.sol";

/// @notice Toolchain smoke test: proves that `forge build` and `forge test` run in the container.
/// @dev Uses plain Solidity assertions (no forge-std yet). forge-std lands with the first real
///      contract test in phase 2. Any revert fails the test.
contract ToolchainTest {
    function testVersionIsStable() public {
        Smoke smoke = new Smoke();
        require(
            keccak256(bytes(smoke.version())) == keccak256(bytes("dapp-tk-basic/toolchain")),
            "unexpected version"
        );
    }

    function testVersionIsNotEmpty() public {
        Smoke smoke = new Smoke();
        require(bytes(smoke.version()).length > 0, "empty version");
    }

    function testChainIdIsLocalAnvil() public view {
        require(block.chainid == 31337, "expected Anvil chain id 31337");
    }
}
