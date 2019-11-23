#!/bin/bash
display_usage() {
   echo "Usage: <receiver> <amount> <fee> <nonce> [expiry]"
}

#Domain separator data
VERSION='1'
CHAIN_ID=99
ADDRESS=$DACH


DOMAIN_SEPARATOR=$(seth keccak \
     $(seth keccak $(seth --from-ascii "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"))\
$(echo $(seth keccak $(seth --from-ascii "Dai Automated Clearing House"))\
$(seth keccak $(seth --from-ascii $VERSION))$(seth --to-uint256 $CHAIN_ID)\
$(seth --to-uint256 $ADDRESS) | sed 's/0x//g'))
#echo $DOMAIN_SEPARATOR

#exit type data
exit_TYPEHASH=$(seth keccak $(seth --from-ascii "Draw(address sender,address receiver,uint256 amount,uint256 fee,uint256 nonce,uint256 expiry,address relayer)"))
echo $exit_TYPEHASH

#join data
SENDER=$ETH_FROM
RECEIVER=$1
AMOUNT=$2
FEE=$3
NONCE=${4:-0}
EXPIRY=${5:-0}
RELAYER=${6:-0x47f5b4DDAFD69A6271f3E15518076e0305a2C722}

MESSAGE=0x1901\
$(echo $DOMAIN_SEPARATOR\
$(seth keccak \
$exit_TYPEHASH\
$(echo $(seth --to-uint256 $SENDER)\
$(seth --to-uint256 $RECEIVER)\
$(seth --to-uint256 $AMOUNT)\
$(seth --to-uint256 $FEE)\
$(seth --to-uint256 $NONCE)\
$(seth --to-uint256 $EXPIRY)\
$(seth --to-uint256 $RELAYER)\
      | sed 's/0x//g')) \
      | sed 's/0x//g')
#echo "MESSAGE" $MESSAGE
SIG=$(ethsign msg --no-prefix --data $MESSAGE)
#echo $SIG
##JSON output
printf '{"join": {"sender":"%s","receiver":"%s","amount":"%s", "fee": "%s", "nonce": "%s", "expiry": "%s", "v": "%s", "r": "%s", "s": "%s"}}\n' "$SENDER" "$RECEIVER" "$AMOUNT" "$FEE" "$NONCE" "$EXPIRY" $((0x$(echo "$SIG" | cut -c 131-132))) $(echo "$SIG" | cut -c 1-66) "0x"$(echo "$SIG" | cut -c 67-130)
