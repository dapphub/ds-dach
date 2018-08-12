# ds-dach
**Dappsys/Dai Automatic Clearing House** is a module that can be plugged in to a token contract to allow users to pay for simple token transfers _with the token being transacted_ rather than paying for gas costs using ether.

A `Cheque` is a signed message containing the following information:

* `sender : address`, the author of the cheque
* `receiver : address`, the receiver of the funds
* `amount : uint256`, a token amount to transfer to the receiver from the `sender`
* `fee : uint256` a token amount to be transfered from the `sender` to whoever submits the cheque to the clearing house
* `nonce: uint256`, for replay protection.

Such cheques can be submitted by anyone to the clearing house through the following clearing function:
```
  function clear(address _sender, address _receiver, uint _amount, uint _fee, uint _nonce, uint8 v, bytes32 r, bytes32 s) public {
    Cheque memory cheque = Cheque({
      sender   : _sender,
      receiver : _receiver,
      amount   : _amount,
      fee      : _fee,
      nonce    : _nonce
    });
    require(verify(cheque, v, r, s));
    require(cheque.nonce == nonces[cheque.src]);
    mover.move(cheque.sender, msg.sender, cheque.fee);
    mover.move(cheque.sender, cheque.receiver, cheque.amount);
    nonces[cheque.sender]++;
  }
```
where `move` is a function which has the authority to update token balances:
```
  function move(address src, address dst, uint wad) public {
    balances[src] = sub(balances[src], wad);
    balances[dst] = add(balances[dst], wad);
  }

```

## Signature generation
The contract uses the typed signature format of [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md) to provide a nice user interface and separate similar looking `Cheques` that might be used by other clearing houses.

## Missing features
- The EIP712 domain separator field should take the address of the verifying contract as input, but right now it is hard coded as 0xdeadbeef.
- Possible gas optimization

## Miner frontrunning
Since cheques can be cleared by anyone, giving the fee to `msg.sender`, if a miner sees a transaction to clear a particular check, they can extract the cheque and clear it themselves, claiming the `fee` for themselves. 

Although this provides an unfortunate situation for people aiming to clear cheques, it does not harm the author of the cheque. Therefore, we do not consider this issue to be of particular concern. One could imagine designing another type of Cheque that explcitly specifies who may clear it, but this is not done in this contract.
