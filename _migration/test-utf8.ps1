[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

Set-Location "C:\Users\deniz\Documents\miraculix"

# Test Commit mit echten Umlauten
$msg = "fix: encoding-test mit Umlauten öäüß"
git commit --allow-empty -m $msg
git log --oneline -1
