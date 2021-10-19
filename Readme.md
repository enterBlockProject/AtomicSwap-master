- A with testnet eth or ERC20, B with mainnet eth or ERC20

- A makes new order locked with A's key, escrow amount to give (90000 gas)

- B makes same, escrow amount to receive, end time shorter than A's order

- A withdraw with account that A wants, unlock (33000 gas)

- B withdraw with account that B wants, unlock

### All info can be seen with events.

### If something wrong like wrong amount or else, there is no cancel. Wait for end time.

### ERC20 address may be set, but not yet.

### 1% fee for owner, can change.
