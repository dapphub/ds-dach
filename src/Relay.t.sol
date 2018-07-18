pragma solidity ^0.4.23;

import "ds-test/test.sol";

import "./Relay.sol";
import "./ECVerify.sol";

contract Lad {
}

contract RelayTest is DSTest, ECVerify {
    Relay relay;
    Mover mover;
    Lad ali;
    Lad bob;
    address cal;
    address del;
    uint8 v = 27;
    bytes32 r = 0x704162c974159f4ec1ed8e453f1cc63852a5d1724e210ea6a64fb1422f24f97d;
    bytes32 s = 0x70caacdf7f94cd16e9018eb5c7b7b7114ae64900a3adbb33bc38caf419c279bd;

    event LogBytes(bytes b);

    function setUp() public {
      relay = new Relay();
      mover = Mover(relay.mover());
      ali = new Lad();
      bob = new Lad();
      cal = 0xd79d4832f5eaf63c69e980a49c1297281b3ba051;
      del = 0xdd2d5d3f7f1b35b7a0601d6a00dbb7d44af58479;
      mover.mint(ali, 100);
      mover.mint(cal,80);
    }

    function testFail_basic_sanity() public {
      assertTrue(false);
    }

    function test_basic_sanity() public {
      assertTrue(true);
      assertTrue(mover.balanceOf(ali) == 100);
      assertTrue(mover.balanceOf(cal) == 80);
    }

    function test_oneMove() public {
      mover.move(ali, bob, 10);
      assertTrue(mover.balanceOf(bob) == 10);
      assertTrue(mover.balanceOf(ali) == 90);
    }

    function test_tryverify() returns (bool,address) {
      bool success;
      address who;
      (success, who) = safer_ecrecover(
                       0x27ec426b29b20cf6acaa918e60ce180a72ab40b5c2ed2add2a264cd6277941c8,
                       27,
                       0x704162c974159f4ec1ed8e453f1cc63852a5d1724e210ea6a64fb1422f24f97d,
                       0x70caacdf7f94cd16e9018eb5c7b7b7114ae64900a3adbb33bc38caf419c279bd
                       );
      assertEq(who,cal);
    }
    /*
    function test_recovery() public {
      bool success;
      address who;
      (success, who) = safer_ecrecover(keccak256(del,2,1,0),v,r,s);
      assertEq(cal,who);
      assertTrue(success);
      }*/

    function test_whatver() public {
      assertEq(mover.balanceOf(cal),80);
      assertEq(mover.balanceOf(del),0);
      assertEq(mover.balanceOf(this),0);
    }
    
    function test_relay() public {
      assertEq(mover.balanceOf(cal),80);
      assertEq(mover.balanceOf(del),0);
      assertEq(mover.balanceOf(this),0);
      relay.relay(del, 2, 1, 0, v, r, s);
      assertEq(mover.balanceOf(cal),77);
      assertEq(mover.balanceOf(del),2);
      assertEq(mover.balanceOf(this),1);
    }
    
    function test_tenRelays() public {
    }
    
}
