Get-ChildItem -Path 'C:\Users' -Recurse -Force `
    -Include *, .* `
    -ErrorAction SilentlyContinue |
Where-Object { $_.FullName -like '*\.ssh\*' } |
Select-Object FullName, LastWriteTime, Length |
Sort-Object FullName
