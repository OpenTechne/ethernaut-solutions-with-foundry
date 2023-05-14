# OpenZeppelin ethernaut solutions with foundry 

## Setup
Create an .env file following .env_example and fill it with your api keys

## To test attacks
```
forge test --match-path test/<level name>.sol 
```

## To attack a real contract

Be careful wen loading your private key to the environment!

Insert the target contract address in `script/<level name>.s.sol`
```
source .env
forge script script/<level name>.s.sol --rpc-url <network name> --broadcast --private-key $PRIVATE_KEY --tc <level name>AttackScript
```

for network names check `[rpc_endpoints]` aliases in `foundry.toml`
