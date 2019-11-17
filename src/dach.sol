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
                                     uint256 deadline, address recipient) external returns (uint256) {}
}

contract DaiLike {
  function transferFrom(address src, address dst, uint wad) public returns (bool) {}
  function approve(address usr, uint wad) public returns (bool) {}
}

contract Pottish {
  function join(uint wad) public {}
  function exit(uint wad) public {}
}

contract DaiJoinLike {
  function join(address usr, uint wad) public {}
  function exit(address usr, uint wad) public {}
}

contract Vattish {
  function hope(address) public {}
}


contract Dach {
  DaiLike dai;
  Uniswappy uniswap;
  Pottish pot;
  DaiJoinLike daiJoin;
  Vattish vat;
  mapping (address => uint256) public nonces;
  mapping (address => uint256) public potBalance;
  string public version;

  // --- EIP712 niceties ---
  bytes32 public DOMAIN_SEPARATOR;
  bytes32 constant public CHEQUE_TYPEHASH = keccak256(
     "Cheque(address sender,address receiver,uint256 amount,uint256 fee,uint256 nonce,uint256 expiry)"
  );

  bytes32 constant public SWAP_TYPEHASH = keccak256(
     "Swap(address sender,uint256 amount,uint256 min_eth,uint256 fee,uint256 nonce,uint256 expiry)"
  );

  // --- Emulate behaviour of field of integers ---
  function add(uint x, uint y) internal pure returns (uint z) {
    require((z = x + y) >= x);
  }

  function sub(uint x, uint y) internal pure returns (uint z) {
    require((z = x - y) <= x);
  }

  constructor(address _dai, address _uniswap, address _pot, address _daiJoin, address _vat, string memory _version, uint256 chainId) public {
    dai = DaiLike(_dai);
    uniswap = Uniswappy(_uniswap);
    pot = Pottish(_pot);
    daiJoin = DaiJoinLike(_daiJoin);
    vat = Vattish(_vat);
    version = _version;
    vat.hope(address(daiJoin));
    DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("Dai Automated Clearing House"),
            keccak256(bytes(_version)),
            chainId,
            address(this)
        ));
  }


  function clear(address sender, address receiver, uint amount, uint fee, uint nonce,
                 uint expiry, uint8 v, bytes32 r, bytes32 s, address taxMan) public {
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
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "cheque expired");
    dai.transferFrom(sender, taxMan, fee);
    dai.transferFrom(sender, receiver, amount);
  }

  function swapToEth(address payable sender, uint amount, uint min_eth, uint fee, uint nonce,
                     uint expiry, uint8 v, bytes32 r, bytes32 s, address taxMan) public returns (uint256) {
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
    dai.transferFrom(sender, address(this), amount);
    dai.transferFrom(sender, taxMan, fee);
    dai.approve(address(uniswap), amount);
    return uniswap.tokenToEthTransferInput(amount, min_eth, now, sender);
  }


  function save(address sender, uint amount, uint fee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s, address taxMan) public {
    //Verify signature 
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "swap expired");
    daiJoin.join(address(this), amount);
    pot.join(amount);
    dai.transferFrom(sender, taxMan, fee);
    potBalance[sender] = add(potBalance[sender], amount);
  }


  function exit(address sender, uint amount, address benefactor, uint fee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s, address taxMan) public {
    //Verify signature stuff
    require(nonce == nonces[sender]++, "invalid nonce");
    require(expiry == 0 || now <= expiry, "swap expired");
    pot.exit(amount);
    daiJoin.exit(benefactor, amount);
    dai.transferFrom(sender, taxMan, fee);
    potBalance[sender] = sub(potBalance[sender], amount);
  }

}
