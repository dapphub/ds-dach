const wallet = require('ethereumjs-wallet');
const util = require('ethereumjs-util');

const Cal = wallet.generate();
const calPrivKey = Cal.getPrivateKey();
const calPubKey = util.bufferToHex(Cal.getPublicKey());
const calAddress = util.bufferToHex(Cal.getAddress());
console.log('cal address:' + calAddress);
const arg1 = util.setLengthLeft(util.toBuffer(2),32);
const arg2 = util.setLengthLeft(util.toBuffer(1),32);
const arg3 = util.setLengthLeft(util.toBuffer(0),32);
//console.log(msg);
const msg = "0xdd2d5d3f7f1b35b7a0601d6a00dbb7d44af58479"+arg1.toString('hex')+arg2.toString('hex')+arg3.toString('hex');
const hash = util.keccak256(msg);
console.log('Hashing the following string: ' + msg);
console.log('Yields hash: ' + util.bufferToHex(hash,'hex'));
const sig = util.ecsign(hash, calPrivKey);
const sign = util.bufferToHex(sig.r,'hex') + util.bufferToHex(sig.s,'hex') + util.bufferToInt(sig.v);
const v = util.bufferToInt(sig.v);
console.log(calAddress + ' signing this hash yields:')
console.log("sig.r:"+ util.bufferToHex(sig.r,'hex'))
console.log("sig.s:"+ util.bufferToHex(sig.s,'hex'))
console.log("sig.v:"+ v)

//console.log(v);
const recoverBuf = util.ecrecover(hash, v, sig.r, sig.s);
const recover = util.bufferToHex(recoverBuf);
//console.log(recover);


