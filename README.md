# ds-relay
Smart Contract infrastructure for relaying signed transactions, allowing users not to worry about paying for gas.

The relay contract can take two different forms, depending on if payments happen on chain or off chain.

## Off chain payment Relay contract
If payments are made off chain, the relay contract is deployed once for every `user`, and takes a signed message containing the following information:

- Receiving address
- Data (EVM bytecode)
- Nonce

After verifying the signature using ECRecover, the Relay contract simply forwards the transaction using DELEGATECALL.

## On chain payment Relay contract 

The on chain payment Relay contract requires payment to be made in any token extended with the following functionality `payOrigin`:
```
mapping (address => uint256) nonces;

function payOrigin(uint amount, uint nonce, bytes sig) public {
    address from = ECRecover(sha3(amount, nonce), sig);
    require (amount <= balances[from] && nonces[from] == nonce)
    require (nonces[from]
    balances[from] -= amount;
    balances[tx.origin] += amount;
    nonces[from] += 1;
}
```

If extendedToken is a contract admitting such a function, then an off chain payment relay contract
would offer the functionality:

```
mapping (address => uint256) nonces;

function tx_relay(address to, uint nonce1, uint nonce2, bytes data, uint fee, bytes sig1, bytes sig2) public {
    address from = ECRecover(sha3(to, nonce1, nonce2, data, fee, sig1), sig2);
    require (nonces[from] == nonce1);
    ExtendedToken.payOrigin(fee, nonce2, sig1)
    external_call(to, data);
    nonces[from] += 1;
}
```
