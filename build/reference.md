# 🔧 PRINTFLOW - Required Tool Versions & Dependencies

## 📋 Complete Version Requirements Matrix

### A. Core Development Tools

| Tool | Minimum Version | Recommended Version | Command to Check | Notes |
|------|----------------|---------------------|------------------|-------|
| **Node.js** | v18.0.0 | v20.11.0 LTS | `node --version` | Required for backend |
| **npm** | v9.0.0 | v10.2.4 | `npm --version` | Node package manager |
| **PostgreSQL** | v14.0 | v15.5 | `psql --version` | Primary database |
| **Redis** | v6.2 | v7.2.4 | `redis-server --version` | Cache & session store |
| **Flutter** | v3.13.0 | v3.16.9 | `flutter --version` | Mobile apps |
| **Dart** | v3.1.0 | v3.2.3 | `dart --version` | Flutter language |
| **Go** | v1.20 | v1.21.5 | `go version` | For OR-Tools (optional) |
| **Python** | v3.10 | v3.11.7 | `python --version` | For AI services |

### B. Backend Dependencies

| Package | Minimum Version | Recommended | Purpose |
|---------|----------------|-------------|---------|
| **express** | ^4.18.0 | 4.18.2 | Web framework |
| **@prisma/client** | ^5.0.0 | 5.7.1 | Database ORM |
| **prisma** | ^5.0.0 | 5.7.1 | Prisma CLI |
| **jsonwebtoken** | ^9.0.0 | 9.0.2 | JWT handling |
| **bcryptjs** | ^2.4.0 | 2.4.3 | Password hashing |
| **socket.io** | ^4.5.0 | 4.5.4 | WebSocket |
| **multer** | ^1.4.5 | 1.4.5-lts.1 | File upload |
| **sharp** | ^0.32.0 | 0.33.1 | Image processing |
| **tesseract.js** | ^5.0.0 | 5.0.5 | OCR engine |
| **aws-sdk** | ^2.1400.0 | 2.1500.0 | AWS services |
| **redis** | ^4.6.0 | 4.6.10 | Redis client |
| **axios** | ^1.4.0 | 1.6.2 | HTTP client |
| **dotenv** | ^16.0.0 | 16.3.1 | Environment variables |
| **cors** | ^2.8.5 | 2.8.5 | CORS middleware |
| **helmet** | ^7.0.0 | 7.1.0 | Security headers |
| **express-rate-limit** | ^6.10.0 | 7.1.5 | Rate limiting |
| **winston** | ^3.10.0 | 3.11.0 | Logging |
| **joi** | ^17.9.0 | 17.11.0 | Validation |
| **nodemailer** | ^6.9.0 | 6.9.7 | Email (fallback) |
| **bull** | ^4.11.0 | 4.11.5 | Queue system |

### C. Frontend Web Dependencies

| Package | Minimum Version | Recommended | Purpose |
|---------|----------------|-------------|---------|
| **react** | ^18.2.0 | 18.2.0 | UI framework |
| **react-dom** | ^18.2.0 | 18.2.0 | DOM rendering |
| **vite** | ^4.4.0 | 5.0.10 | Build tool |
| **tailwindcss** | ^3.3.0 | 3.4.0 | CSS framework |
| **axios** | ^1.4.0 | 1.6.2 | HTTP client |
| **socket.io-client** | ^4.5.0 | 4.5.4 | WebSocket client |
| **react-router-dom** | ^6.14.0 | 6.20.1 | Routing |
| **recharts** | ^2.7.0 | 2.10.3 | Charts |
| **@react-google-maps/api** | ^2.19.0 | 2.19.2 | Google Maps |
| **react-query** | ^3.39.0 | 3.39.3 | Data fetching |
| **zustand** | ^4.3.0 | 4.4.7 | State management |
| **react-hook-form** | ^7.45.0 | 7.48.2 | Form handling |
| **framer-motion** | ^10.12.0 | 10.16.16 | Animations |
| **date-fns** | ^2.30.0 | 2.30.0 | Date formatting |

### D. Flutter/Dart Dependencies (pubspec.yaml)

```yaml
# Minimum versions required
environment:
  sdk: '>=3.1.0 <4.0.0'
  flutter: '>=3.13.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Core
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  provider: ^6.0.5
  shared_preferences: ^2.2.2
  
  # Authentication
  amazon_cognito_identity_dart_2: ^3.1.0
  google_sign_in: ^6.1.0
  facebook_auth: ^6.0.0
  sign_in_with_apple: ^5.0.0
  local_auth: ^2.1.6
  
  # Networking
  dio: ^5.3.2
  socket_io_client: ^2.0.3
  web_socket_channel: ^2.4.0
  
  # Location & Maps
  geolocator: ^10.1.0
  google_maps_flutter: ^2.5.0
  geocoding: ^2.1.1
  
  # UI Components
  flutter_svg: ^2.0.9
  cached_network_image: ^3.2.3
  shimmer: ^3.0.0
  pull_to_refresh: ^2.0.0
  bottom_navy_bar: ^6.0.0
  
  # Payment & QR
  qr_flutter: ^4.1.0
  mobile_scanner: ^3.5.7
  
  # Security
  flutter_secure_storage: ^9.0.0
  cryptography: ^2.5.0
  totp: ^2.1.0
  
  # AI & ML
  tflite_flutter: ^0.10.4
  image: ^4.1.3
  
  # Utils
  intl: ^0.18.1
  url_launcher: ^6.1.14
  package_info_plus: ^5.0.1
  device_info_plus: ^9.1.0
  connectivity_plus: ^5.0.2
  
  # Ads & Monetization
  google_mobile_ads: ^5.0.0
  
  # Notifications
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  flutter_local_notifications: ^16.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  flutter_native_splash: ^2.3.8
  flutter_launcher_icons: ^0.13.1
```

### E. Infrastructure & DevOps Tools

| Tool | Minimum Version | Recommended | Purpose |
|------|----------------|-------------|---------|
| **Docker** | v20.10.0 | v24.0.7 | Containerization |
| **Docker Compose** | v2.20.0 | v2.23.0 | Multi-container |
| **Terraform** | v1.5.0 | v1.6.6 | Infrastructure as Code |
| **AWS CLI** | v2.13.0 | v2.13.35 | AWS management |
| **kubectl** | v1.27.0 | v1.29.0 | Kubernetes |
| **Helm** | v3.12.0 | v3.13.2 | K8s package manager |
| **PM2** | v5.3.0 | v5.3.0 | Process manager |
| **nginx** | v1.22.0 | v1.24.0 | Web server |
| **certbot** | v2.0.0 | v2.8.0 | SSL certificates |
| **Git** | v2.30.0 | v2.43.0 | Version control |
| **GitHub CLI** | v2.30.0 | v2.42.0 | GitHub operations |

### F. System Requirements (OS Level)

```bash
# Ubuntu/Debian System Packages
sudo apt-get install -y \
  build-essential \
  curl \
  wget \
  git \
  unzip \
  zip \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common \
  libpq-dev \
  libssl-dev \
  libreadline-dev \
  libbz2-dev \
  libsqlite3-dev \
  libffi-dev \
  zlib1g-dev \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libgif-dev \
  libwebp-dev \
  libavcodec-dev \
  libavformat-dev \
  libswscale-dev \
  libopenblas-dev \
  liblapack-dev \
  libatlas-base-dev \
  tesseract-ocr \
  tesseract-ocr-ind \
  poppler-utils \
  imagemagick \
  ffmpeg

# For macOS (via Homebrew)
brew install \
  postgresql@15 \
  redis \
  nginx \
  tesseract \
  poppler \
  imagemagick \
  ffmpeg \
  awscli \
  terraform \
  kubectl \
  helm
```

### G. AWS Service Versions Required

| AWS Service | Configuration | Notes |
|-------------|--------------|-------|
| **Cognito** | User Pool with WebAuthn support | Requires Essentials tier |
| **RDS PostgreSQL** | Version 15.5+ | Supports pgcrypto, postgis |
| **ElastiCache Redis** | Version 7.1+ | Supports RedisJSON |
| **SES** | Production access | For bulk email |
| **SQS** | Standard or FIFO | For email queue |
| **SNS** | Standard | For email events |
| **ECS** | Fargate launch type | For containers |
| **S3** | Latest | For file storage |
| **CloudFront** | Latest | CDN for static assets |
| **Lambda** | Node.js 18.x | For triggers |
| **API Gateway** | HTTP API or REST | For endpoints |

---

## 📥 Installation Scripts by OS

### Ubuntu/Debian 22.04/24.04

```bash
#!/bin/bash
# install-tools-ubuntu.sh

echo "🚀 Installing PRINTFLOW Required Tools on Ubuntu..."

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PostgreSQL 15
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y postgresql-15 postgresql-contrib-15

# Install Redis 7
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
sudo apt-get update
sudo apt-get install -y redis

# Install Flutter
cd ~
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
export PATH="$PATH:$HOME/flutter/bin"
flutter precache

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install PM2
sudo npm install -g pm2

# Install system packages
sudo apt-get install -y \
  tesseract-ocr \
  tesseract-ocr-ind \
  poppler-utils \
  imagemagick \
  ffmpeg \
  nginx \
  certbot \
  python3-certbot-nginx

echo "✅ All tools installed successfully!"
echo "Please restart your terminal or run: source ~/.bashrc"
```

### macOS (Intel/Apple Silicon)

```bash
#!/bin/bash
# install-tools-macos.sh

echo "🚀 Installing PRINTFLOW Required Tools on macOS..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Node.js 20
brew install node@20
brew link --overwrite node@20

# Install PostgreSQL 15
brew install postgresql@15
brew services start postgresql@15

# Install Redis
brew install redis
brew services start redis

# Install Flutter
brew install --cask flutter
flutter precache

# Install Docker Desktop
brew install --cask docker

# Install Terraform
brew install terraform

# Install AWS CLI
brew install awscli

# Install kubectl
brew install kubectl

# Install Helm
brew install helm

# Install PM2
npm install -g pm2

# Install additional tools
brew install \
  tesseract \
  poppler \
  imagemagick \
  ffmpeg \
  nginx \
  certbot

echo "✅ All tools installed successfully!"
```

### Windows (WSL2 or PowerShell)

```powershell
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
```

---

## 🔍 Version Validation Script

```javascript
// scripts/check-versions.js
const { execSync } = require('child_process');
const semver = require('semver');

const requirements = {
  node: { min: '18.0.0', recommended: '20.11.0' },
  npm: { min: '9.0.0', recommended: '10.2.4' },
  docker: { min: '20.10.0', recommended: '24.0.7' },
  dockerCompose: { min: '2.20.0', recommended: '2.23.0' },
  terraform: { min: '1.5.0', recommended: '1.6.6' },
  aws: { min: '2.13.0', recommended: '2.13.35' },
  flutter: { min: '3.13.0', recommended: '3.16.9' },
  postgres: { min: '14.0', recommended: '15.5' },
  redis: { min: '6.2', recommended: '7.2.4' }
};

function getVersion(command, pattern) {
  try {
    const output = execSync(command).toString();
    const match = output.match(pattern);
    return match ? match[1] : null;
  } catch {
    return null;
  }
}

console.log('🔍 Checking Tool Versions...\n');

const results = {};

// Check Node.js
results.node = getVersion('node --version', /v(\d+\.\d+\.\d+)/);
// Check npm
results.npm = getVersion('npm --version', /(\d+\.\d+\.\d+)/);
// Check Docker
results.docker = getVersion('docker --version', /(\d+\.\d+\.\d+)/);
// Check Docker Compose
results.dockerCompose = getVersion('docker-compose --version', /v(\d+\.\d+\.\d+)/);
// Check Terraform
results.terraform = getVersion('terraform --version', /v(\d+\.\d+\.\d+)/);
// Check AWS CLI
results.aws = getVersion('aws --version', /aws-cli\/(\d+\.\d+\.\d+)/);
// Check Flutter
results.flutter = getVersion('flutter --version', /Flutter (\d+\.\d+\.\d+)/);
// Check PostgreSQL
results.postgres = getVersion('psql --version', /(\d+\.\d+)/);
// Check Redis
results.redis = getVersion('redis-server --version', /v=(\d+\.\d+\.\d+)/);

console.table(results);

let allPass = true;
for (const [tool, version] of Object.entries(results)) {
  const req = requirements[tool];
  if (!version) {
    console.log(`❌ ${tool}: NOT INSTALLED`);
    allPass = false;
  } else if (semver.lt(version, req.min)) {
    console.log(`⚠️  ${tool}: ${version} (min: ${req.min}, recommended: ${req.recommended}) - UPGRADE RECOMMENDED`);
  } else {
    console.log(`✅ ${tool}: ${version}`);
  }
}

console.log('\n' + (allPass ? '✅ All tools meet minimum requirements!' : '⚠️ Some tools need installation/upgrade'));
```

---

## 📦 Production Deployment Version Lock

```dockerfile
# Dockerfile with locked versions
FROM node:20.11.0-slim

# Install system dependencies with specific versions
RUN apt-get update && apt-get install -y \
    postgresql-client-15 \
    redis-tools=5:7.2.4-1* \
    tesseract-ocr=5.3.3-1 \
    poppler-utils=22.12.0-2 \
    && rm -rf /var/lib/apt/lists/*

# Install PM2 globally
RUN npm install -g pm2@5.3.0

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npx prisma@5.7.1 generate

EXPOSE 3000
CMD ["pm2-runtime", "ecosystem.config.js"]
```

---
