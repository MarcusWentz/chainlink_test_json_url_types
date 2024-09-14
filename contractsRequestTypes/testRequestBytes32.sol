// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract testRequestBytes32 is ChainlinkClient {

    using Chainlink for Chainlink.Request;

    address constant oracleSepolia = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD;
    string constant jobIdSepolia = "7da2702f37fd48e5b1b9a5715e3509b6";
    uint256 public constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18 (0.1 LINK)
    bytes32 public currentPrice;

    event RequestEthereumPriceFulfilled(
        bytes32 indexed requestId,
        bytes32 indexed price
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
        req._add("path", "bytes32");
        //req.addInt("times", 100);
        _sendChainlinkRequestTo(oracleSepolia, req, ORACLE_PAYMENT);
    }

    function fulfillEthereumPrice(
        bytes32 _requestId,
        bytes calldata _id
    ) public recordChainlinkFulfillment(_requestId) {
        bytes32 bytes32Id = bytes32(_id);
        emit RequestEthereumPriceFulfilled(_requestId, bytes32Id);
        currentPrice = bytes32Id;
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
