/// dach.sol -- An automated clearing house

// Copyright (C) 2019  Martin Lundfall

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity >=0.4.23;

import {Dai} from "dss/dai.sol";
import {Chai} from "chai/chai.sol";

contract Uniswappy {
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_tokens,
                                     uint256 deadline, address recipient) public returns (uint256) ;
}

/*The Dai automated clearing house demonstrates the generality of the `permit()` pattern,
allowing users perform the following actions without paying for gas. 

1. Dai transfers (clear)
2. Sell dai for eth (swapToEth)
3. Convert dai to chai (join)
4. Convert chai to dai (draw)

All `fee`s are denominated in dai 
and paid to the `relayer`.

Actions 1-3 requires that the user calls `dai.permit(dach)` before operating,
action 4 requires `chai.permit(dach)`.
*/

contract Dach {
  Dai public dai;
  Chai public chai;
  Uniswappy public uniswap;
  
  mapping (address => uint256) public nonces;
  string public constant version = "1";
  string public constant name = "Dai Automated Clearing House";

  // --- EIP712 niceties ---
  bytes32 public DOMAIN_SEPARATOR;

  //keccak256("Cheque(address sender,address receiver,uint256 amount,uint256 fee,uint256 nonce,uint256 expiry,address relayer)");
  bytes32 constant public CHEQUE_TYPEHASH = 0x5c32085874a8e37b372097d5c7fabfa97e843d5d09490d4bc53748425c2289bf;

  //keccak256("Swap(address sender,uint256 amount,uint256 min_eth,uint256 fee,uint256 nonce,uint256 expiry,address relayer)");
  bytes32 constant public SWAP_TYPEHASH = 0x4ccd19bde5e17e8dd1d6fea249311cb6d9b45e0e4ae9ff0eef3d49372c1eee64;

  //keccak256("Join(address sender,address receiver,uint256 amount,uint256 fee,uint256 nonce,uint256 expiry,address relayer)");
  bytes32 constant public JOIN_TYPEHASH = 0xa057b6b80cbcf1fc4ee4d77dd1db61541437441e96559a0d015d833994e31779;

  //keccak256("Draw(address sender,address receiver,uint256 amount,uint256 fee,uint256 nonce,uint256 expiry,address relayer)");
  bytes32 constant public DRAW_TYPEHASH = 0x50fb495ae763cde7b2d33d59ebf4500d4e9bf6405ff4f725042f2f6e2299abb9;
 
  constructor(address _dai, address _uniswap, address _chai, uint256 chainId) public {
    dai = Dai(_dai);
    chai = Chai(_chai);
    uniswap = Uniswappy(_uniswap);
    DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId,
            address(this)
        ));
  }

  function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
  }


  function digest(bytes32 hash, address src, address dst, uint amount, uint fee,
                  uint nonce, uint expiry, address relayer) internal view returns (bytes32) {
         return keccak256(abi.encodePacked(
                   "\x19\x01",
                   DOMAIN_SEPARATOR,
                   keccak256(abi.encode(hash,
                                        src,
                                        dst,
                                        amount,
                                        fee,
                                        nonce,
                                        expiry,
                                        relayer))
                ));
    }

  function clear(address sender, address receiver, uint amount, uint fee, uint nonce,
                 uint expiry, uint8 v, bytes32 r, bytes32 s, address relayer) public {
    require(sender == ecrecover(digest(CHEQUE_TYPEHASH, sender, receiver, amount, fee, nonce, expiry, relayer), v, r, s), "invalid cheque");
    require(nonce  == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "cheque expired");
    require(relayer == msg.sender);
    dai.transferFrom(sender, msg.sender, fee);
    dai.transferFrom(sender, receiver, amount);
  }

  function swapToEth(address payable sender, uint amount, uint min_eth, uint fee, uint nonce,
                     uint expiry, uint8 v, bytes32 r, bytes32 s, address relayer) public returns (uint256) {
    require(sender == ecrecover(
      keccak256(abi.encodePacked(
         "\x19\x01",
         DOMAIN_SEPARATOR,
         keccak256(abi.encode(SWAP_TYPEHASH,
                              sender,
                              amount,
                              min_eth,
                              fee,
                              nonce,
                              expiry,
                              relayer)))), v, r, s), "invalid swap");
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "swap expired");
    require(relayer == msg.sender, "wrong relayer");
    dai.transferFrom(sender, address(this), amount);
    dai.transferFrom(sender, msg.sender, fee);
    dai.approve(address(uniswap), amount);
    return uniswap.tokenToEthTransferInput(amount, min_eth, now, sender);
  }

  //Convert @amount dai to chai
  function joinChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                    uint expiry, uint8 v, bytes32 r, bytes32 s, address relayer) public {
    require(sender == ecrecover(digest(JOIN_TYPEHASH, sender, receiver, amount, fee, nonce, expiry, relayer), v, r, s), "invalid join");
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "join expired");
    require(relayer == msg.sender, "wrong relayer");
    dai.transferFrom(sender, address(this), amount);
    dai.approve(address(chai), amount);
    chai.join(receiver, amount);
    dai.transferFrom(sender, msg.sender, fee);
  }
  //Convert enough chai to yield @amount dai
  //Requires chai.permit before executing
  function drawChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                    uint expiry, uint8 v, bytes32 r, bytes32 s, address relayer) public {
    require(sender == ecrecover(digest(DRAW_TYPEHASH, sender, receiver, amount, fee, nonce, expiry, relayer), v, r, s), "invalid draw");
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "draw expired");
    require(relayer == msg.sender, "wrong relayer");
    chai.draw(sender, add(amount, fee));
    dai.transfer(receiver, amount);
    dai.transfer(msg.sender, fee);
  }
}
