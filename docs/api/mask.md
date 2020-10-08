# Data masking

Data masking is the process of hiding original data with modified content (characters or other data.)
The main reason for applying masking to a data field is to protect data that is classified as personally identifiable information, sensitive personal data, or commercially sensitive data.

On Peatio beneficiary account number is masked on API level.

| Field | Mask |  Comment |
|---|---|---|
| Account number | 42 **** **** 2345  | First 2 number and last 4 digits  |