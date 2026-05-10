const fs = require('fs');
const path = require('path');

const directories = [
  'printflow/backend/src/controllers',
  'printflow/backend/src/services',
  'printflow/backend/src/middleware',
  'printflow/backend/src/models',
  'printflow/backend/src/routes',
  'printflow/backend/src/utils',
  'printflow/backend/src/config',
  'printflow/backend/src/workers',
  'printflow/backend/prisma',
  'printflow/backend/uploads/documents',
  'printflow/backend/uploads/prints',
  'printflow/backend/uploads/temp',
  'printflow/backend/logs',
  'printflow/backend/tests/unit',
  'printflow/backend/tests/integration',
  'printflow/backend/tests/e2e',
  'printflow/frontend-web/public',
  'printflow/frontend-web/src/assets/images',
  'printflow/frontend-web/src/assets/icons',
  'printflow/frontend-web/src/assets/fonts',
  'printflow/frontend-web/src/components/common',
  'printflow/frontend-web/src/components/dashboard',
  'printflow/frontend-web/src/components/orders',
  'printflow/frontend-web/src/components/drivers',
  'printflow/frontend-web/src/components/campaigns',
  'printflow/frontend-web/src/components/ai',
  'printflow/frontend-web/src/hooks',
  'printflow/frontend-web/src/contexts',
  'printflow/frontend-web/src/services',
  'printflow/frontend-web/src/utils',
  'printflow/frontend-web/src/styles',
  'printflow/frontend-web/src/pages',
  'printflow/mobile-user/lib/screens',
  'printflow/mobile-user/lib/widgets',
  'printflow/mobile-user/lib/providers',
  'printflow/mobile-user/lib/services',
  'printflow/mobile-user/lib/models',
  'printflow/mobile-user/lib/utils',
  'printflow/mobile-user/android',
  'printflow/mobile-user/ios',
  'printflow/mobile-driver/lib/screens',
  'printflow/mobile-driver/lib/widgets',
  'printflow/mobile-driver/lib/providers',
  'printflow/mobile-driver/lib/services',
  'printflow/mobile-partner/lib/screens',
  'printflow/mobile-partner/lib/widgets',
  'printflow/mobile-partner/lib/providers',
  'printflow/mobile-partner/lib/services',
  'printflow/infrastructure/terraform/modules/vpc',
  'printflow/infrastructure/terraform/modules/ecs',
  'printflow/infrastructure/terraform/modules/rds',
  'printflow/infrastructure/terraform/modules/cognito',
  'printflow/infrastructure/terraform/modules/ses',
  'printflow/infrastructure/kubernetes',
  'printflow/infrastructure/docker',
  'printflow/infrastructure/scripts',
  'printflow/lambda/pre-signup-recaptcha',
  'printflow/lambda/custom-message',
  'printflow/lambda/cognito-triggers',
  'printflow/lambda/email-events-handler',
  'printflow/docs/api',
  'printflow/docs/guides',
  'printflow/docs/architecture',
  'printflow/scripts',
  'printflow/.github/workflows'
];

directories.forEach(dir => {
  const fullPath = path.join(process.cwd(), dir);
  if (!fs.existsSync(fullPath)) {
    fs.mkdirSync(fullPath, { recursive: true });
    console.log(`✅ Created: ${dir}`);
  }
});

console.log('\n🎉 All directories created successfully!');