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
    address cal = 0x29c76e6ad8f28bb1004902578fb108c507be341b;
    address del = 0xdd2d5d3f7f1b35b7a0601d6a00dbb7d44af58479;
    uint wad = 2;
    uint fee = 1;
    uint nonce = 0;
    //output from generateSigs.js; a signed, typed message from cal of a cheque
    //specifying a 2 dai transfer to del with a 1 dai fee to msg.sender
    string sig = '0x657e67032cfa3b1efd231d5b046e07bb2ecf1547b9d32551c3793fe156516ad00a811c31e50e64adea6a7209836fc22d7746a67d3953a342453857daf26704841b';
    //the string above is not used anywhere, we decompose it into the following params:
    uint8 v = 27;
    bytes32 r = 0x657e67032cfa3b1efd231d5b046e07bb2ecf1547b9d32551c3793fe156516ad0;
    bytes32 s = 0x0a811c31e50e64adea6a7209836fc22d7746a67d3953a342453857daf2670484;

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

    function test_domain_sep() public {
      assertEq(relay.DOMAIN_SEPARATOR(), 0xcefc3efd3e12749cf6849e637e99c71315209ccc419b8d6a6c967a71e7edd86b);
    }

    function test_cheque_typehash() public {
      assertEq(relay.CHEQUE_TYPEHASH(), 0x7eb02bee71261bc514e2fa911172c93f74df70e1e57befd4a626f0ab26784c42);
    }

    function test_cheque_hash() public {
      assertEq(relay.hash(cal, del, 2, 1, 0), 0x2383830092099c0f994fe5f6771c373c12bcfcafc664b5ab235b372265068b17);
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

    function test_replay_protection() public {
      //Resubmitting the same cheque results in a throw
      relay.relay(cal, del, 2, 1, 0, v, r, s);
      assertEq(mover.balanceOf(cal),77);
      assertEq(mover.balanceOf(del),2);
      assertEq(mover.balanceOf(this),1);
    }
}
