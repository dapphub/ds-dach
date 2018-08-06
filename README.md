# ds-relay
Now features typed signing à la [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md)!

Simple relay functionality that can be added to a token contract to allow users to pay for simple token transfers _with the token being transacted_ rather than paying for gas costs using ether.

To use this functionality, the user signs a message which specifies:

* `src`, the `address` of the sender (as a security precaution; ecrecover may return random addresses given faulty input.)
* `dst`, the `address` of the receiver
* `wad`, the token amount to transfer to the receiver
* `fee`, the token amount to transfer to the relayer
* `nonce`, for replay protection.

The signed message, along with the information above is then relayed off chain to some `relayer`,
which is willing to pay the gas cost for executing the transfer in exchange for the `fee`.

The relay function requires authority to call a `move`-function which updates token balances:
```
  function move(address src, address dst, uint wad) public {
    balances[src] = sub(balances[src], wad);
    balances[dst] = add(balances[dst], wad);
  }

```
the on chain relay verification function can be defined as:
```
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
```
where `nonces` is a mapping of addresses to uints.

## Signature generation
As soon as [this PR is merged into Metamask](https://github.com/MetaMask/metamask-extension/pull/4803#issuecomment-407828165) typed signatures can be generated using the metamask browser plug in. 

For testing purposes there is an easy script `generateSigs.js` that shows how to use [eth-sig-util](https://github.com/MetaMask/eth-sig-util) for this purpose.

## Missing features
- The EIP712 domain separator field should take the address of the verifying contract as input, but right now it is hard coded as 0xdeadbeef.
- Possible gas optimization
