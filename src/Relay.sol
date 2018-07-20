pragma solidity ^0.4.23;
import "ds-math/math.sol";

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

contract Relay {
  mapping (address => uint256) public nonces;
  Mover public mover;

  constructor() {
    mover = new Mover();
  }

      function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {
        // Credit due to @axic for this wrapper.
        // We do our own memory management here. Solidity uses memory offset
        // 0x40 to store the current end of memory. We write past it (as
        // writes are memory extensions), but don't update the offset so
        // Solidity will reuse it. The memory used here is only needed for
        // this context.

        // FIXME: inline assembly can't access return values
        bool ret;
        address addr;

        assembly {
            let size := mload(0x40)
            mstore(size, hash)
            mstore(add(size, 32), v)
            mstore(add(size, 64), r)
            mstore(add(size, 96), s)

            // NOTE: we can reuse the request memory because we deal with
            //       the return code
            ret := call(3000, 1, 0, size, 128, size, 32)
            addr := mload(size)
        }

        return (ret, addr);
    }

  
  function relay(address dst, uint wad, uint fee, uint nonce, uint8 v, bytes32 r, bytes32 s) public {
    bytes32 hash = keccak256(dst, wad, fee, nonce);
    address src;
    bool success;
    (success, src) = safer_ecrecover(hash,v,r,s);
    require(success);
    require(nonce == nonces[src]);
    mover.move(src, msg.sender, fee);
    mover.move(src, dst, wad);
    nonces[dst]++;
  }
}
