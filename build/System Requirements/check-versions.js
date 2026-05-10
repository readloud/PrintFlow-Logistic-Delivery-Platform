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