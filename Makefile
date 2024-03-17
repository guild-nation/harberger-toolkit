# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

.PHONY: build

build:
	forge build

test:
	forge test

format:
	forge fmt

gas:
	forge test --gas-report

snapshot:
	forge snapshot

coverage:
	forge coverage

lcov:
	forge coverage --report lcov

anvil:
	anvil

slither:
	slither .

solc:
	solc-select install $(SOLC) && solc-select use $(SOLC)

deploy-lib:
	forge create --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --optimize --verify src/AddressBook.sol:AddressBook

deploy:
	forge create --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --libraries $(LIBRARIES) --constructor-args $(BASE_URI) $(OWNER) --optimize --verify src/Proto.sol:Proto
