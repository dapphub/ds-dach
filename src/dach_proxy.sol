pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

interface DachLike {
    function daiCheque(address sender, address receiver, uint amount, uint fee, uint nonce,
                       uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) external;
    function daiSwap(address sender, uint amount, uint min_eth, uint fee, uint nonce,
                     uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) external returns (uint256);
    
    function joinChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                      uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) external;
    function chaiCheque(address sender, address receiver, uint amount, uint fee, uint nonce,
                        uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) external;
    function chaiSwap(address sender, uint amount, uint min_eth, uint fee, uint nonce,
                      uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) external returns (uint256);
    function exitChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                      uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s) external;

}

//wow solidity 0.6.0
struct signedPermit {
    address holder;
    address spender;
    uint256 nonce;
    uint256 expiry;
    bool allowed;
    uint8 v;
    bytes32 r;
    bytes32 s;
}


interface DaiLike {
  function permit(signedPermit calldata) external;
}


contract withPermit {

  DachLike dach;
  DaiLike dai;
  DaiLike chai; 

  constructor(address _dai, address _chai, address _dach) public {
    dach = DachLike(_dach);
    dai  = DaiLike(_dai);
    chai = DaiLike(_chai);
  }
  function daiCheque(address sender, address receiver, uint amount, uint fee, uint nonce,
                     uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                     signedPermit calldata daiPermit) external {
    dai.permit(daiPermit);
    dach.daiCheque(sender, receiver, amount, fee, nonce, expiry, relayer, v, r, s);
  }

  function daiSwap(address sender, uint amount, uint min_eth, uint fee, uint nonce,
                   uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                   signedPermit calldata daiPermit) external returns (uint256) {
    dai.permit(daiPermit);
    return dach.daiSwap(sender, amount, min_eth, fee, nonce, expiry, relayer, v, r, s);
  }

  function joinChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                    uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                    signedPermit calldata daiPermit) external {
    dai.permit(daiPermit);
    dach.joinChai(sender, receiver, amount, fee, nonce, expiry, relayer, v, r, s);
  }

  function chaiSwap(address sender, uint amount, uint min_eth, uint fee, uint nonce,
                    uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                    signedPermit calldata chaiPermit) external returns (uint256) {
    chai.permit(chaiPermit);
    return dach.chaiSwap(sender, amount, min_eth, fee, nonce, expiry, relayer, v, r, s);
  }
      
  function chaiCheque(address sender, address receiver, uint amount, uint fee, uint nonce,
                     uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                     signedPermit calldata chaiPermit) external {
    chai.permit(chaiPermit);
    dach.chaiCheque(sender, receiver, amount, fee, nonce, expiry, relayer, v, r, s);
  }

  function exitChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                    uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                    signedPermit calldata chaiPermit) external {
    chai.permit(chaiPermit);
    dach.exitChai(sender, receiver, amount, fee, nonce, expiry, relayer, v, r, s);
  }
}
