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
    address cal = 0xb68ffcb68368f38e6f10fb92042f828a21dc2855;
    address del = 0xdd2d5d3f7f1b35b7a0601d6a00dbb7d44af58479;
    uint wad = 2;
    uint fee = 1;
    uint nonce = 0;
    uint8 v = 28;
    bytes32 r = 0x504ee47c8e23b9802794a52b86a70eef703b1ab0c2c176eab34631f0e8c0113a;
    bytes32 s = 0x6491585a82273d6f9647cdaa6c06299f91b0aa633ff8027301708ae993a519e1;
    bytes32 hash = 0xd1c4aaacba9d481c25d3648b6fb10b01fbb7945dd0aef35199372ccb43e6dab9;

    event LogBytes(bytes b);

    function setUp() public {
      relay = new Relay();
      mover = Mover(relay.mover());
      ali = new Lad();
      bob = new Lad();
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
                       keccak256(del,wad,fee,nonce),
                       v,
                       r,
                       s
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
      relay.relay(del, 2, 1, 0, v, r, s, cal);
      assertEq(mover.balanceOf(cal),77);
      assertEq(mover.balanceOf(del),2);
      assertEq(mover.balanceOf(this),1);
    }
    
    function test_tenRelays() public {
    }
    
}
