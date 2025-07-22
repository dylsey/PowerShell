# Define timestamped filename
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputPath = "$env:USERPROFILE\Desktop\PythonModules-$timestamp.txt"

# Write header
"Python Module Inventory - $timestamp" | Out-File -FilePath $outputPath
"======================================" | Out-File -Append $outputPath

# Step 1: pip list
"`n[1] Installed packages via pip list:`n" | Out-File -Append $outputPath
python -m pip list | Out-File -Append $outputPath

# Step 2: importable modules (uses Python's pkgutil)
"`n[2] Importable modules via pkgutil:`n" | Out-File -Append $outputPath
$script = @'
import pkgutil
modules = sorted([m.name for m in pkgutil.iter_modules()])
print("\n".join(modules))
'@
python -c $script | Out-File -Append $outputPath

# Step 3: Confirm completion
Write-Host "Module inventory saved to: $outputPath" -ForegroundColor Green
