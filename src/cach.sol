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

contract Uniswappy {
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_tokens,
                                     uint256 deadline, address recipient) public returns (uint256) {}
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) payable public returns (uint256) {}
}

contract DaiLike {
  function transferFrom(address src, address dst, uint wad) public returns (bool) {}
  function transfer(address dst, uint wad) public returns (bool) {}
}

contract ChaiLike {
  function join(address dst, uint wad) public;
  function exit(address dst, uint wad) public;
  function approve(address usr, uint wad) public returns (bool) {}
  function transferFrom(address src, address dst, uint wad) public returns (bool) {}
}


contract Dach {
  DaiLike public dai;
  ChaiLike public chai;
  Uniswappy public uniswap;
  mapping (address => uint256) public nonces;
  string public constant version = "1";
  string public constant name = "Chai Automated Clearing House";

  // --- EIP712 niceties ---
  bytes32 public DOMAIN_SEPARATOR;

  //keccak256("Cheque(address sender,address receiver,uint256 amount,uint256 fee,uint256 nonce,uint256 expiry)");
  bytes32 constant public CHEQUE_TYPEHASH = 0xed59b9c88e6a1d59aab46de8b69d13aa3a824b6ca8afb56e8398be3dcb0363d4;

  //keccak256("Swap(address sender,uint256 amount,uint256 min_eth,uint256 fee,uint256 nonce,uint256 expiry)");
  bytes32 constant public SWAP_TYPEHASH = 0x33971c92a3406b72ebe36f29bb63a906f3b2e543c06bf27eaafb0d2d20429d7b;

  //keccak256("Exit...
  bytes32 constant public EXIT_TYPEHASH = 0x33971c92a3406b72ebe36f29bb63a906f3b2e543c06bf27eaafb0d2d20429d7b;

  
  constructor(address _dai, address _uniswap, address _chai, uint256 chainId) public {
    dai = DaiLike(_dai);
    uniswap = Uniswappy(_uniswap);
    DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId,
            address(this)
        ));
  }


  //All fees paid in chai in this contract
  function clear(address sender, address receiver, uint amount, uint fee, uint nonce,
                 uint expiry, uint8 v, bytes32 r, bytes32 s, address taxman) public {
    bytes32 digest =
      keccak256(abi.encodePacked(
         "\x19\x01",
         DOMAIN_SEPARATOR,
         keccak256(abi.encode(CHEQUE_TYPEHASH,
                              sender,
                              receiver,
                              amount,
                              fee,
                              nonce,
                              expiry))
      ));
    require(sender == ecrecover(digest, v, r, s), "invalid cheque");
    require(nonce  == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "cheque expired");
    chai.transferFrom(sender, taxman, fee);
    chai.transferFrom(sender, receiver, amount);
  }

  function swapToEth(address payable sender, uint amount, uint min_eth, uint fee, uint nonce,
                     uint expiry, uint8 v, bytes32 r, bytes32 s, address taxman) public returns (uint256) {
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
                              expiry)))), v, r, s), "invalid swap");
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "swap expired");
    chai.transferFrom(sender, address(this), amount);
    chai.transferFrom(sender, taxman, fee);
    chai.approve(address(uniswap), amount);
    return uniswap.tokenToEthTransferInput(amount, min_eth, now, sender);
  }

  function exitChai(address sender, address to, uint amount, uint fee, uint nonce,
                    uint expiry, uint8 v, bytes32 r, bytes32 s, address taxman) public {
    require(sender == ecrecover(
      keccak256(abi.encodePacked(
         "\x19\x01",
         DOMAIN_SEPARATOR,
         keccak256(abi.encode(EXIT_TYPEHASH,
                              sender,
                              to,
                              amount,
                              fee,
                              nonce,
                              expiry)))), v, r, s), "invalid exit");
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "exit expired");
    chai.exit(sender, amount);
    dai.transfer(sender, amount);
    chai.transferFrom(sender, taxman, fee);
  }
}
