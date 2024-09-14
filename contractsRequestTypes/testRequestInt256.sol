// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract testRequestInt256 is ChainlinkClient {

    using Chainlink for Chainlink.Request;

    address constant oracleSepolia = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD;
    string constant jobIdSepolia = "fcf4140d696d44b687012232948bdd5d";
    uint256 public constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18 (0.1 LINK)
    int256 public currentPrice;

    event RequestEthereumPriceFulfilled(
        bytes32 indexed requestId,
        int256 indexed price
    );

    constructor() {
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
    }

    function requestEthereumPrice() public {
        Chainlink.Request memory req = _buildChainlinkRequest(
            stringToBytes32(jobIdSepolia),
            address(this),
            this.fulfillEthereumPrice.selector
        );
        req._add(
            "get",
            "https://marcuswentz.github.io/chainlink_test_json_url_types/"
        );
        req._add("path", "int256");
        req._addInt("times", 100);
        _sendChainlinkRequestTo(oracleSepolia, req, ORACLE_PAYMENT);
    }

    function fulfillEthereumPrice(
        bytes32 _requestId,
        int256 _price
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestEthereumPriceFulfilled(_requestId, _price);
        currentPrice = _price;
    }

    function stringToBytes32(
        string memory source
    ) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
