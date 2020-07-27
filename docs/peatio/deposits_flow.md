# Peatio deposit flow
## Previous version
In previous version we had deposit collection flow based on amqp daemon (deposit_collection_fees, deposit_collection)

Legacy deposit process diagram:

![image](../images/peatio/legacy_deposits_flow.png)

1. Blockchain daemon process blocks and filter platform deposits.
2. We are waiting for the N number of confirmations.
3. Blockchain daemon produces AMQP message for deposit_collection_fees daemon.
4. deposit_collection_fees daemon trying to collect fees if needed (erc20 case) and after collection immediately produce a message for the next daemon (deposit_collection).

deposit_collection daemon processing message and trying to collect deposit depending on the deposit spread.

The main problem for this approach that we don't wait till the transaction that we generated in the deposit_collection_fees daemon successfully executed and we are failing on deposit collection in the last step (it happens mostly for each erc20 deposit). Also, there is some chance that we can miss amqp message due to server instability.

## New deposit collection flow based on SQL worker

We decided to remove to AMQP base deposit daemons and create a new deposit daemon that will work on deposit states changes and will prevent immediate proceeding of erc20 deposits.

New deposit process diagram:

![image](../images/peatio/new_deposits_flow.png)

1. Blockchain daemon process blocks and filter platform deposits.
2. We are waiting for the N number of confirmations.
3. In the deposit daemons we select each 60s deposits with state `processing` and `fee_processing`.
4. For `processing` deposits we are checking if plugin implement method `prepare_deposit_collection!` if it doesn't we immediately process the deposit and collect deposit to the `hot`, `warm`, `cold` wallets. If plugin implement method `prepare_deposit_collection!` daemon processing of collection fees and change deposit state to `fee_processing`.
For deposits with `fee_processing` state, we select each minute deposits that have `updated_at` older than 5 minutes and process them. With time condition we are sure that fee transaction has already been executed.
