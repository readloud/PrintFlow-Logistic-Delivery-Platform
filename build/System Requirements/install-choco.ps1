# PowerShell (Admin) - install-choco.ps1
Write-Host "Installing PRINTFLOW Required Tools on Windows..." -ForegroundColor Green

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install tools via Chocolatey
choco install nodejs-lts microsoft-openjdk17 androidstudio flutter postgresql15 redis docker-desktop terraform awscli kubectl helm nginx -y

# Install PM2
npm install -g pm2

Write-Host "✅ Installation complete! Please restart your terminal."