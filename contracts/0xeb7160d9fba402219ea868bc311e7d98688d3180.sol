pragma solidity ^0.4.13;




contract Verifier{
function verifyTx(
uint[2],
uint[2],
uint[2][2],
uint[2],
uint[2],
uint[2],
uint[2],
uint[2],
address
) public pure returns (bool){}




/**
@notice © Copyright 2018 EYGS LLP and/or other members of the global Ernst & Young/EY network; pat. pending.
*/
function getInputBits(uint, address) public view returns(bytes8){}
}




contract TokenShield{




/**
@notice © Copyright 2018 EYGS LLP and/or other members of the global Ernst & Young/EY network; pat. pending.




Contract to enable the management of hidden non fungible toke transactions.
*/




address public owner;
bytes8[merkleWidth] private ns; //store spent token nullifiers
bytes8[merkleWidth] private ds; //store the double-spend prevention hashes
uint constant merkleWidth = 256;
uint constant merkleDepth = 9;
uint constant lastRow = merkleDepth-1;
bytes8[merkleWidth] private zs; //array holding the tokens.  Basically the bottom row of the merkle tree
uint private zCount; //remember the number of tokens we hold
uint private nCount; //remember the number of tokens we spent
bytes8[] private roots; //holds each root we've calculated so that we can pull the one relevant to the prover
uint public currentRootIndex; //holds the index for the current root so that the
//prover can provide it later and this contract can look up the relevant root
Verifier mv; //the verification smart contract that the mint function uses
Verifier tv; //the verification smart contract that the transfer function uses
Verifier jv; //the verification smart contract that the join function uses
Verifier sv; //the verification smart contract that the split function uses
//uint i; //just a loop counter, should be local but moved here to preserve stack space
struct Proof { //recast this as a struct because otherwise, as a set of local variable, it takes too much stack space
uint[2] a;
uint[2] a_p;
uint[2][2] b;
uint[2] b_p;
uint[2] c;
uint[2] c_p;
uint[2] h;
uint[2] k;
}




mapping(address => Proof) private proofs;




constructor(address mintVerifier, address transferVerifier, address joinVerifier, address splitVerifier) public {
//TODO - you can get a way with a single, generic verifier.
owner = msg.sender;
mv = Verifier(mintVerifier);
tv = Verifier(transferVerifier);
jv = Verifier(joinVerifier);
sv = Verifier(splitVerifier);
}








//only owner  modifier
modifier onlyOwner () {
require(msg.sender == owner);
_;
}




/**
self destruct added by westlad
*/
function close() public onlyOwner {
selfdestruct(owner);
}








function getMintVerifier() public view returns(address){
return address(mv);
}




function getTransferVerifier() public view returns(address){
return address(tv);
}




function getJoinVerifier() public view returns(address){
return address(jv);
}




function getSplitVerifier() public view returns(address){
return address(sv);
}




/**
The mint function accepts a Preventifier, H(A), where A is the assetHash; a
Z token and a proof that both the token and the Preventifier contain A.
It's done as an array because the stack on EVM is too small to hold all the locals otherwise.
For the same reason, the proof is set up by calling setProofParams first.
*/
function mint() public {
//first, verify the proof
bool result = mv.verifyTx(
proofs[msg.sender].a,
proofs[msg.sender].a_p,
proofs[msg.sender].b,
proofs[msg.sender].b_p,
proofs[msg.sender].c,
proofs[msg.sender].c_p,
proofs[msg.sender].h,
proofs[msg.sender].k,
msg.sender);




require(result); //the proof must check out.
bytes8 d = mv.getInputBits(0, msg.sender); //recover the input params from MintVerifier
bytes8 z = mv.getInputBits(64, msg.sender);
for (uint i=0; i<zCount; i++) { //check the preventifier doesn't exist
require(ds[i]!= d);
}
zs[zCount] = z; //add the commitment
ds[zCount++] = d; //add the preventifier
bytes8 root = merkle(0,0); //work out the Merkle root as it's now different
currentRootIndex = roots.push(root)-1; //and save it to the list
}




/**
The transfer function transfers a commitment to a new owner
*/
function transfer() public {
bool result = tv.verifyTx(
proofs[msg.sender].a,
proofs[msg.sender].a_p,
proofs[msg.sender].b,
proofs[msg.sender].b_p,
proofs[msg.sender].c,
proofs[msg.sender].c_p,
proofs[msg.sender].h,
proofs[msg.sender].k,
msg.sender);
require(result); //the proof must verify. The spice must flow.
bytes8 n = tv.getInputBits(0, msg.sender);
bytes8 z = tv.getInputBits(128, msg.sender);
for (uint i=0; i<nCount; i++) { //check this is an unspent commitment
require(ns[i]!=n);
}
ns[nCount++] = n; //remember we spent it
zs[zCount++] = z; //add Bob's token to the list of tokens
bytes8 root = merkle(0,0); //work out the Merkle root as it's now different
currentRootIndex = roots.push(root)-1; //and save it to the list
}




/**
The join function joins multiple commitments into one z-commitment and
transfers to the public of key recipient specified
*/
function join() public {
//verification contract
bool result = jv.verifyTx(
proofs[msg.sender].a,
proofs[msg.sender].a_p,
proofs[msg.sender].b,
proofs[msg.sender].b_p,
proofs[msg.sender].c,
proofs[msg.sender].c_p,
proofs[msg.sender].h,
proofs[msg.sender].k,
msg.sender);
require(result); //the proof must verify. The spice must flow.
bytes8 na1 = jv.getInputBits(0, msg.sender);
bytes8 na2 = jv.getInputBits(64, msg.sender);
bytes8 zb = jv.getInputBits(192, msg.sender);
bytes8 db = jv.getInputBits(256, msg.sender);
for (uint i=0; i<nCount; i++) { //check this is an unspent commitment
require(ns[i]!=na1 && ns[i]!=na2);
}
for (uint j=0; j<zCount; j++) { //check the preventifier doesn't exist
require(ds[j]!= db);
}
ns[nCount++] = na1; //remember we spent it
ns[nCount++] = na2; //remember we spent it
zs[zCount] = zb; //add the commitment
ds[zCount++] = db; //add the preventifier
bytes8 root = merkle(0,0); //work out the Merkle root as it's now different
currentRootIndex = roots.push(root)-1; //and save it to the list
}




/**
The split function splits a commitment into multiple commitments and transfers
to the public of key recipient specified
*/
function split() public {
//verification contract
bool result = sv.verifyTx(
proofs[msg.sender].a,
proofs[msg.sender].a_p,
proofs[msg.sender].b,
proofs[msg.sender].b_p,
proofs[msg.sender].c,
proofs[msg.sender].c_p,
proofs[msg.sender].h,
proofs[msg.sender].k,
msg.sender);
require(result); //the proof must verify. The spice must flow.
bytes8 na = sv.getInputBits(0, msg.sender);
bytes8 zb1 = sv.getInputBits(128, msg.sender);
bytes8 zb2 = sv.getInputBits(192, msg.sender);
bytes8 db1 = sv.getInputBits(256, msg.sender); //TODO do not add if already in the list of double spend preventifier
bytes8 db2 = sv.getInputBits(320, msg.sender); //TODO do not add if already in the list of double spend preventifier
for (uint i=0; i<nCount; i++) { //check this is an unspent coin
require(ns[i]!=na);
}
ns[nCount++] = na; //remember we spent it
zs[zCount] = zb1; //add the commitment
ds[zCount++] = db1; //add the preventifier
zs[zCount] = zb2; //add the commitment
ds[zCount++] = db2; //add the preventifier
bytes8 root = merkle(0,0); //work out the Merkle root as it's now different
currentRootIndex = roots.push(root)-1; //and save it to the list
}




/**
This function is only needed because otherwise mint and transfer use too many
local variables for the limited stack space. Rather than pass a proof as
parameters to these functions (more logical)
*/
function setProofParams(
uint[2] a,
uint[2] a_p,
uint[2][2] b,
uint[2] b_p,
uint[2] c,
uint[2] c_p,
uint[2] h,
uint[2] k)
public {
//this is long, think of a better way
proofs[msg.sender].a[0] = a[0];
proofs[msg.sender].a[1] = a[1];
proofs[msg.sender].a_p[0] = a_p[0];
proofs[msg.sender].a_p[1] = a_p[1];
proofs[msg.sender].b[0][0] = b[0][0];
proofs[msg.sender].b[0][1] = b[0][1];
proofs[msg.sender].b[1][0] = b[1][0];
proofs[msg.sender].b[1][1] = b[1][1];
proofs[msg.sender].b_p[0] = b_p[0];
proofs[msg.sender].b_p[1] = b_p[1];
proofs[msg.sender].c[0] = c[0];
proofs[msg.sender].c[1] = c[1];
proofs[msg.sender].c_p[0] = c_p[0];
proofs[msg.sender].c_p[1] = c_p[1];
proofs[msg.sender].h[0] = h[0];
proofs[msg.sender].h[1] = h[1];
proofs[msg.sender].k[0] = k[0];
proofs[msg.sender].k[1] = k[1];
}




function getTokens() public view returns(bytes8[merkleWidth], uint root) {
//need the commitments to compute a proof and also an index to look up the current
//root.
return (zs,currentRootIndex);
}




/**
Function to return the root that was current at rootIndex
*/
function getRoot(uint rootIndex) view public returns(bytes8) {
return roots[rootIndex];
}




function computeMerkle() public view returns (bytes8){//for backwards compat
return merkle(0,0);
}




function merkle(uint r, uint t) public view returns (bytes8) {
//This is a recursive approach, which seems efficient but we do end up
//calculating the whole tree fro scratch each time.  Need to look at storing
//intermediate values and seeing if that will make it cheaper.
if (r==lastRow) {
return zs[t];
} else {
return bytes8(sha256(merkle(r+1,2*t)^merkle(r+1,2*t+1))<<192);
}
}
}