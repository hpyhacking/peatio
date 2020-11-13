## Global Withdraw Limits

This document describes how withdraw limits works in opendax peatio.

Withdraw limits schema:

| Term           | Definition                                       |
| -------------- | ------------------------------------------------ |
| Group          | Member group. Will be used to select limit       |
| KYC Level      | Member KYC level. Will be used to select limit   |
| 24 hour limit  | 24 hour limit in platform currency e.g. USD      |
| 1 month limit  | 1 month limit in platform currency e.g. USD      |

Every user has a KyC level (starts from 0) and a group (default is 'any').
The KYC level has a higher priority than group match.

For example a member with kyc_level 2 and group 'vip-0' will match the following rules in order:
The first is the highest priority.

|KYC level|Group    |Priority|
|---------|---------|--------|
| 2       | vip-0 | 1      |
| 2       | any   | 2      |
| any   | vip-0 | 3      |
| any   | any   | 4      |

Withdraw limits check flow:

1. If the user hasn't reached any withdrawal limits, the system process the withdrawal request automatically from the currency 'Hot wallet'. If the 'Hot wallet' doesn't have enough funds to process the withdrawal request the system will throw an error. In this situation, the admin needs to replenish the 'Hot wallet'.

2. If the user reached at least one of withdrawal limits (24 hours or 1 month) the system accepts the request, locks the user funds but doesn't process the withdraw automatically. Admin can manually reject or process this withdrawal request from the 'Hot wallet' or process it manually from the warm wallet.

More info about [Peatio Financial Flow](https://www.openware.com/sdk/guides/operator/financial-flow.html) and [Peatio Wallet Guidelines](https://www.openware.com/sdk/guides/operator/wallet-guidelines.html).
