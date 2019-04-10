pragma solidity >=0.4.23;
import "./dai.sol";

// Solidity Interface

contract Uniswap {
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_tokens, uint256 deadline, address recipient) external returns (uint256  eth_bought);
}


contract Dach {
  Dai dai;
  Uniswap uniswap;
  mapping (address => uint256) public nonces;

  // --- EIP712 niceties ---
  bytes32 public DOMAIN_SEPARATOR;
  bytes32 constant public CHEQUE_TYPEHASH = keccak256(
     "Cheque(address sender,address receiver,uint256 amount,uint256 fee,uint256 nonce, uint256 deadline)"
  );

  bytes32 constant public SWAP_TYPEHASH = keccak256(
     "Swap(address sender,uint256 amount,uint256 min_eth,uint256 fee,uint256 nonce,uint256 deadline)"
  );

  constructor(Dai _dai, Uniswap _uniswap, string memory version, uint256 chainId) public {
    dai = _dai;
    uniswap = _uniswap;
    DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("Dai Automated Clearing House"),
            keccak256(bytes(version)),
            chainId,
            address(this)
        ));
  }

  
  function clear(address sender, address receiver, uint amount, uint fee,
                 uint nonce, uint deadline, uint8 v, bytes32 r, bytes32 s) public
  {
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
                              deadline))
      ));
    require(sender == ecrecover(digest, v, r, s), "invalid cheque");
    require(nonce == nonces[sender]++);
    dai.transferFrom(sender, msg.sender, fee);
    dai.transferFrom(sender, receiver, amount);
  }

  function swapToEth(address sender, uint amount, uint min_eth, uint fee,
                     uint nonce, uint deadline, uint8 v, bytes32 r, bytes32 s) public {
    bytes32 digest =
      keccak256(abi.encodePacked(
         "\x19\x01",
         DOMAIN_SEPARATOR,
         keccak256(abi.encode(SWAP_TYPEHASH,
                              sender,
                              amount,
                              min_eth,
                              fee,
                              nonce,
                              deadline))
      ));
    require(sender == ecrecover(digest, v, r, s), "invalid swap");
    require(nonce == nonces[sender]++);    
    dai.transferFrom(sender, address(this), amount);
    uniswap.tokenToEthTransferInput(amount, min_eth, deadline, sender);
    dai.transferFrom(sender, msg.sender, fee);
  }
}
