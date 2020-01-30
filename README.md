# ds-dach
Deployed on mainnet at https://etherscan.io/address/0x64043a98f097fD6ef0D3ad41588a6B0424723b3a#code

The Dai Automated Clearing House can perform the following actions:

- Clearing of Dai and Chai cheques
- Clearing of Dai -> Eth or Chai -> Eth uniswap sales
- Clearing of Chai joins or exits

For example,
A `Cheque` is a signed message containing the following information:

* `sender : address`, the author of the cheque
* `receiver : address`, the receiver of the funds
* `amount : uint256`, a token amount to transfer to the receiver from the `sender`
* `expiry : uint256`, a time after which the cheque can no longer be cleared
* `fee : uint256` a token amount to be transfered from the `sender` to whoever submits the cheque to the clearing house
* `nonce: uint256`, for replay protection
* `relayer : address`, the address authorized to clear the transaction

Anyone who obtains such a signed message can clear them, paying the gas cost of the transaction in exchange for the fee.

## Signature generation
The contract uses the typed signature format of [EIP-712](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md) to provide a nice user interface and separate similar looking `Cheques` that might be used by other clearing houses. 

If you want to try it out, here's a guide that utilizes the api at https://api.stablecoin.services to clear a dai transfer.
This requires that you have `seth` and `ethsign` installed, and a local wallet with some dai or chai available. To install `seth` and `ethsign`, see [dapp.tools](https://dapp.tools).

# Generating the signed message:
First, generate a dai cheque using the script provided at bin/daiCheque. For example, to generate a cheque of `0.1` Dai to the ethereum foundation multisig at `0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae`, paying 0.2 dai in tx fees.

First, set the environment ETH_FROM to whatever account you would like to sign the cheque with:
```sh
export ETH_FROM=0xacab #your acc
```
then generate the cheque and store it in a file we'll call `cheque.json`:
```sh
./bin/daiCheque 0xde0b295669a9fd93d5f28d9ec85e40f4cb697bae $(seth --to-wei 0.1 'ether') $(seth --to-wei 0.2 'ether') > cheque.json
```
Before clearing the cheque, you need to authorize the `dach` contract:
```sh
seth send 0x6b175474e89094c44da98b954eedeac495271d0f "approve(address,uint256)" 0x64043a98f097fD6ef0D3ad41588a6B0424723b3a $(seth --to-int256 -1)
```
we can then submit the cheque to be cleared using the stablecoin.services api:
```sh
curl -X POST https://api.stablecoin.services/v1/daiCheque -d @cheque.json -H "Content-Type: application/json"
```
