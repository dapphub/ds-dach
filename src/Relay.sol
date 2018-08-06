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
  bytes32 public DOMAIN_SEPARATOR;
  
  Mover public mover;

  bytes32 constant EIP712DOMAIN_TYPEHASH = keccak256(
        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
  );

  bytes32 constant public CHEQUE_TYPEHASH = keccak256(
       "Cheque(address src,address dst,uint256 wad,uint256 fee,uint256 nonce)"
  );


  struct EIP712Domain {
    string  name;
    string  version;
    uint256 chainId;
    address verifyingContract;
  }

  struct Cheque {
    address src;
    address dst;
    uint256 wad;
    uint256 fee;
    uint256 nonce;
  }

  constructor() {
    mover = new Mover();
    DOMAIN_SEPARATOR = hash("Dai relay", "1", 1, 0xdeadbeef);
  }

  function hash(string name, string version, uint256 chainId, address verifyingContract) pure returns (bytes32) {
        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH,
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId,
            verifyingContract
        ));
  }

  function hash(address src, address dst, uint256 wad, uint256 fee, uint256 nonce) pure returns (bytes32) {
        return keccak256(abi.encode(
            CHEQUE_TYPEHASH,
            src,
            dst,
            wad,
            fee,
            nonce
        ));
    }


  function verify(Cheque cheque, uint8 v, bytes32 r, bytes32 s) internal returns (bool) {
    bytes32 digest = keccak256(abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR,
                        hash(cheque.src, cheque.dst, cheque.wad, cheque.fee, cheque.nonce)
                     ));
    return ecrecover(digest, v, r, s) == cheque.src;
  }

  
  function relay(address _src, address _dst, uint _wad, uint _fee, uint _nonce, uint8 v, bytes32 r, bytes32 s) public {
    Cheque memory cheque = Cheque({
      src : _src,
      dst : _dst,
      wad : _wad,
      fee : _fee,
      nonce : _nonce
    });
    require(verify(cheque, v, r, s));
    require(cheque.nonce == nonces[cheque.src]);
    mover.move(cheque.src, msg.sender, cheque.fee);
    mover.move(cheque.src, cheque.dst, cheque.wad);
    nonces[cheque.src]++;
  }
}
