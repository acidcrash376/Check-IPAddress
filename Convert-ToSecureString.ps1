"YourPasswordHere" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File ".\creds.txt"
