const wallet = require('ethereumjs-wallet');
const util = require('ethereumjs-util');
const rlp = require('rlp');

const Carol = wallet.generate();
const carolPrivKey = Carol.getPrivateKey();
const carolPubKey = util.bufferToHex(Carol.getPublicKey());
const carolAddress = util.bufferToHex(Carol.getAddress());
console.log('carol PubKey:' + carolPubKey);
console.log('carol address:' + carolAddress);
const arg1 = util.setLengthLeft(util.toBuffer(2),32);
const arg2 = util.setLengthLeft(util.toBuffer(1),32);
const arg3 = util.setLengthLeft(util.toBuffer(0),32);
const rlpEncargs = rlp.encode([arg1,arg2]);
console.log('rlpencoded args: ' + rlpEncargs.toString('hex'));
const msg = rlpEncargs.toString('hex');
//console.log(msg);
const hash = util.keccak256("0xdd2d5d3f7f1b35b7a0601d6a00dbb7d44af58479"+arg1+arg2+arg3);
console.log('hash: ' + util.bufferToHex(hash,'hex'));
const sig = util.ecsign(hash, carolPrivKey);
//console.log(sig);
const sign = util.bufferToHex(sig.r,'hex') + util.bufferToHex(sig.s,'hex') + util.bufferToInt(sig.v);
const v = util.bufferToInt(sig.v);
console.log("sig.r:"+ util.bufferToHex(sig.r,'hex'))
console.log("sig.s:"+ util.bufferToHex(sig.s,'hex'))
console.log("sig.v:"+ v)
console.log('sign: ' + sign);

//console.log(v);
const recoverBuf = util.ecrecover(hash, v, sig.r, sig.s);
const recover = util.bufferToHex(recoverBuf);
//console.log(recover);


