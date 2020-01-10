pragma solidity >=0.5.12;
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

interface DaiLike {
  function permit(address, address, uint256, uint256, bool, uint8, bytes32, bytes32) external;
}

contract withPermit {

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

  DaiLike  public constant dai  = DaiLike(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);
  DaiLike  public constant chai = DaiLike(0xB641957b6c29310926110848dB2d464C8C3c3f38);
  DachLike public constant dach = DachLike(0x2ef865CA017912c872826e25736A7A11f94235AF);

  function daiCheque(address sender, address receiver, uint amount, uint fee, uint nonce,
                     uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                     signedPermit calldata daiPermit) external {
    dai.permit(daiPermit.holder, daiPermit.spender, daiPermit.nonce, daiPermit.expiry,
               daiPermit.allowed, daiPermit.v, daiPermit.r, daiPermit.s);
    dach.daiCheque(sender, receiver, amount, fee, nonce, expiry, relayer, v, r, s);
  }

  function daiSwap(address sender, uint amount, uint min_eth, uint fee, uint nonce,
                   uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                   signedPermit calldata daiPermit) external returns (uint256) {
    dai.permit(daiPermit.holder, daiPermit.spender, daiPermit.nonce, daiPermit.expiry,
               daiPermit.allowed, daiPermit.v, daiPermit.r, daiPermit.s);
    return dach.daiSwap(sender, amount, min_eth, fee, nonce, expiry, relayer, v, r, s);
  }

  function joinChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                    uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                    signedPermit calldata daiPermit) external {
    dai.permit(daiPermit.holder, daiPermit.spender, daiPermit.nonce, daiPermit.expiry,
               daiPermit.allowed, daiPermit.v, daiPermit.r, daiPermit.s);
    dach.joinChai(sender, receiver, amount, fee, nonce, expiry, relayer, v, r, s);
  }

  function chaiSwap(address sender, uint amount, uint min_eth, uint fee, uint nonce,
                    uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                    signedPermit calldata chaiPermit) external returns (uint256) {
    chai.permit(chaiPermit.holder, chaiPermit.spender, chaiPermit.nonce, chaiPermit.expiry,
                chaiPermit.allowed, chaiPermit.v, chaiPermit.r, chaiPermit.s);
    return dach.chaiSwap(sender, amount, min_eth, fee, nonce, expiry, relayer, v, r, s);
  }
      
  function chaiCheque(address sender, address receiver, uint amount, uint fee, uint nonce,
                      uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                      signedPermit calldata chaiPermit) external {
    chai.permit(chaiPermit.holder, chaiPermit.spender, chaiPermit.nonce, chaiPermit.expiry,
                chaiPermit.allowed, chaiPermit.v, chaiPermit.r, chaiPermit.s);
    dach.chaiCheque(sender, receiver, amount, fee, nonce, expiry, relayer, v, r, s);
  }

  function exitChai(address sender, address receiver, uint amount, uint fee, uint nonce,
                    uint expiry, address relayer, uint8 v, bytes32 r, bytes32 s,
                    signedPermit calldata chaiPermit) external {
    chai.permit(chaiPermit.holder, chaiPermit.spender, chaiPermit.nonce, chaiPermit.expiry,
                chaiPermit.allowed, chaiPermit.v, chaiPermit.r, chaiPermit.s);
    dach.exitChai(sender, receiver, amount, fee, nonce, expiry, relayer, v, r, s);
  }
}
