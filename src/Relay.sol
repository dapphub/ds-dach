pragma solidity ^0.4.23;
import "ds-math/math.sol";
import "./ECVerify.sol";

contract Mover is DSMath {
  mapping (address => uint256) balances;

  function balanceOf(address lad) public returns (uint) {
    return balances[lad];
  }

  function move(address src, address dst, uint wad) public returns (bool) {
    balances[src] = sub(balances[src], wad);
    balances[dst] = add(balances[dst], wad);
    return true;
  }

  function mint(address lad, uint wad) public {
    balances[lad] = add(balances[lad], wad);
  }
}

contract Relay is ECVerify {
  mapping (address => uint256) public nonces;
  Mover public mover;

  constructor() {
    mover = new Mover();
  }
  
  function relay(address dst, uint wad, uint fee, uint nonce, uint8 v, bytes32 r, bytes32 s) public returns (bool) {
    bytes32 hash = keccak256(dst, wad, fee, nonce);
    address src;
    bool success;
    (success, src) = safer_ecrecover(hash,v,r,s);
    require(success);
    require(nonce == nonces[src]);
    mover.move(src, msg.sender, fee);
    mover.move(src, dst, wad);
    nonces[dst]++;
    return true;
  }
}
