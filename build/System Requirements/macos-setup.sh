#!/bin/bash
# macOS (Intel/Apple Silicon)
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