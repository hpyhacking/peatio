# Adding new ERC20-based currency

## Configuration

First, you will need to update your configuration files (`config/currencies.yml` and `config/markets.yml`).

In `config/currencies.yml` copy the configurations of TRST (WeTrust) and assign your contact address to `erc20_contract_address`.

Change `precision` and `base_factor` accordingly as per the ERC20 token requirements. 
