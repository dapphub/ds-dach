pragma solidity ^0.4.23;

import "ds-test/test.sol";

import "./Relay.sol";

contract Lad {
}

contract RelayTest is DSTest {
    Relay relay;
    Mover mover;
    Lad ali;
    Lad bob;
    address cal = 0xb494c6117809585c35f3b48105206128a7681eb0;
    address del = 0xdd2d5d3f7f1b35b7a0601d6a00dbb7d44af58479;
    uint wad = 2;
    uint fee = 1;
    uint nonce = 0;
    uint8 v = 27;
    bytes32 r = 0x3265510535b97060ab7090772697088d1575614c775f79ea53456d3971fb8862;
    bytes32 s = 0x2e92bb13db00825610090026e29cd47f49b72b718f94c75a5dfa0bf55ad1f492;
    bytes32 hash = 0x355765b4ff2950ea8e453ae241b64f5b899685fa8a0fd0e331244756d2e555df;

    function setUp() public {
      relay = new Relay();
      mover = Mover(relay.mover());
      ali = new Lad();
      bob = new Lad();
      mover.mint(ali, 100);
      mover.mint(cal,80);
      assertTrue(mover.balanceOf(ali) == 100);      
      assertEq(mover.balanceOf(cal),80);
    }

    function testFail_basic_sanity() public {
      assertTrue(false);
    }

    function test_basic_sanity() public {
      assertTrue(true);
      assertTrue(mover.balanceOf(cal) == 80);
    }

    function test_oneMove() public {
      assertTrue(mover.balanceOf(ali) == 100);      
      assertEq(mover.balanceOf(bob),0);
      mover.move(ali, bob, 10);
      assertTrue(mover.balanceOf(bob) == 10);
      assertTrue(mover.balanceOf(ali) == 90);
    }

    function test_relay() public {
      assertEq(mover.balanceOf(cal),80);
      assertEq(mover.balanceOf(del),0);
      assertEq(mover.balanceOf(this),0);
      relay.relay(cal, del, 2, 1, 0, v, r, s);
      assertEq(mover.balanceOf(cal),77);
      assertEq(mover.balanceOf(del),2);
      assertEq(mover.balanceOf(this),1);
    }
     
}
