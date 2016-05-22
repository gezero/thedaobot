# thedaobot

The plan is to create a bot that will automatically confirm the amount of The DAO tokens a person controls by checking a signature from a comment that requests such confirmation.

# Usage

1. Create a signature
2. Spawn the bot with your post

## How to create a signature:
1. Launch your geth client (mist wallet)
2. Open command line
3. geth attach
4. msg = web3.sha3('Schoolbus')
..* "d030d9a04df643f62a1502b017f51c41a659268091abbd20e2de97b935724d7c"
5. signature = web3.eth.sign(web3.eth.accounts[0], msg)
6. enter your passphrase
..* "0xf4dffb108315560563e30657c1a5d7942f54bf321593797f08f84ff0601643e2683eb468ddd5f5d9c5bea00a9661beb6e042d335706763957f40f81d790e7aa301"