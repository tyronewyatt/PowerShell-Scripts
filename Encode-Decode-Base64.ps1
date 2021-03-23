# Encode to Base64
$String = "SecretMessage"
[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))

# Decode from Base64
$String = "U2VjcmV0TWVzc2FnZQ=="
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($String))

# Example usage
& "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy Bypass -encodedCommand "JABwAHIAbwBmAGkAbABlACAAPQAgAG4AZQB0AHMAaAAgAGEAZAB2AGYAaQByAGUAdwBhAGwAbAAgAG0AbwBuAGkAdABvAHIAIABzAGgAbwB3ACAAYwB1AHIAcgBlAG4AdABwAHIAbwBmAGkAbABlAAoAaQBmACAAKAAkAHAAcgBvAGYAaQBsAGUAIAAtAG0AYQB0AGMAaAAgACIAUAB1AGIAbABpAGMAIABQAHIAbwBmAGkAbABlADoAIgApACAACgB7AAoAIAAgACAAIABSAGUAcwB0AGEAcgB0AC0AUwBlAHIAdgBpAGMAZQAgAC0AbgBhAG0AZQAgAE4AbABhAFMAdgBjACAALQBGAG8AcgBjAGUACgB9AAoAZQB4AGkAdAA="