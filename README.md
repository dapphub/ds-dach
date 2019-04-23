# ds-dach
The clearing house can clear cheques, allowing users to transfer tokens without eth.

A `Cheque` is a signed message containing the following information:

* `sender : address`, the author of the cheque
* `receiver : address`, the receiver of the funds
* `amount : uint256`, a token amount to transfer to the receiver from the `sender`
* `expiry : uint256`, a time after which the cheque can no longer be cleared
* `fee : uint256` a token amount to be transfered from the `sender` to whoever submits the cheque to the clearing house
* `nonce: uint256`, for replay protection

Anyone who obtains such a signed message can clear them, paying the gas cost of the transaction in exchange for the fee.

## Signature generation
The contract uses the typed signature format of [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md) to provide a nice user interface and separate similar looking `Cheques` that might be used by other clearing houses. You can generate cheques with the accompanying `seth` script [here](/bin/cheque).

## Miner frontrunning
Since cheques can be cleared by anyone, giving the fee to `msg.sender`, if a miner sees a transaction to clear a particular check, they can extract the cheque and clear it themselves, claiming the `fee` for themselves. 

Although this provides an unfortunate situation for people aiming to clear cheques, it does not harm the signer of the cheque. Therefore, we do not consider this issue to be of particular concern. One could imagine designing another type of Cheque that explcitly specifies who may clear it, but this is not done in this contract.
