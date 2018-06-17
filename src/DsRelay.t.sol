pragma solidity ^0.4.23;

import "ds-test/test.sol";

import "./DsRelay.sol";

contract DsRelayTest is DSTest {
    DsRelay relay;

    function setUp() public {
        relay = new DsRelay();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
