# Copy paste script ini langsung di PowerShell (bukan dari file):

# Create root directory
New-Item -ItemType Directory -Force -Path "printflow"

# Backend
$backendDirs = @(
    "printflow/backend/src/controllers",
    "printflow/backend/src/services", 
    "printflow/backend/src/middleware",
    "printflow/backend/src/models",
    "printflow/backend/src/routes",
    "printflow/backend/src/utils",
    "printflow/backend/src/config",
    "printflow/backend/src/workers",
    "printflow/backend/prisma",
    "printflow/backend/uploads/documents",
    "printflow/backend/uploads/prints",
    "printflow/backend/uploads/temp",
    "printflow/backend/logs",
    "printflow/backend/tests/unit",
    "printflow/backend/tests/integration",
    "printflow/backend/tests/e2e"
)

foreach ($dir in $backendDirs) {
    New-Item -ItemType Directory -Force -Path $dir
    Write-Host "Created: $dir" -ForegroundColor Green
}

# Frontend Web
$webDirs = @(
    "printflow/frontend-web/public",
    "printflow/frontend-web/src/assets/images",
    "printflow/frontend-web/src/assets/icons",
    "printflow/frontend-web/src/assets/fonts",
    "printflow/frontend-web/src/components/common",
    "printflow/frontend-web/src/components/dashboard",
    "printflow/frontend-web/src/components/orders",
    "printflow/frontend-web/src/components/drivers",
    "printflow/frontend-web/src/components/campaigns",
    "printflow/frontend-web/src/components/ai",
    "printflow/frontend-web/src/hooks",
    "printflow/frontend-web/src/contexts",
    "printflow/frontend-web/src/services",
    "printflow/frontend-web/src/utils",
    "printflow/frontend-web/src/styles",
    "printflow/frontend-web/src/pages"
)

foreach ($dir in $webDirs) {
    New-Item -ItemType Directory -Force -Path $dir
    Write-Host "Created: $dir" -ForegroundColor Green
}

# Mobile Apps
$mobileDirs = @(
    "printflow/mobile-user/lib/screens",
    "printflow/mobile-user/lib/widgets", 
    "printflow/mobile-user/lib/providers",
    "printflow/mobile-user/lib/services",
    "printflow/mobile-user/lib/models",
    "printflow/mobile-user/lib/utils",
    "printflow/mobile-user/android",
    "printflow/mobile-user/ios",
    "printflow/mobile-driver/lib/screens",
    "printflow/mobile-driver/lib/widgets",
    "printflow/mobile-driver/lib/providers",
    "printflow/mobile-driver/lib/services",
    "printflow/mobile-partner/lib/screens",
    "printflow/mobile-partner/lib/widgets",
    "printflow/mobile-partner/lib/providers",
    "printflow/mobile-partner/lib/services"
)

foreach ($dir in $mobileDirs) {
    New-Item -ItemType Directory -Force -Path $dir
    Write-Host "Created: $dir" -ForegroundColor Green
}

# Infrastructure
$infraDirs = @(
    "printflow/infrastructure/terraform/modules/vpc",
    "printflow/infrastructure/terraform/modules/ecs",
    "printflow/infrastructure/terraform/modules/rds",
    "printflow/infrastructure/terraform/modules/cognito",
    "printflow/infrastructure/terraform/modules/ses",
    "printflow/infrastructure/kubernetes",
    "printflow/infrastructure/docker",
    "printflow/infrastructure/scripts"
)

foreach ($dir in $infraDirs) {
    New-Item -ItemType Directory -Force -Path $dir
    Write-Host "Created: $dir" -ForegroundColor Green
}

# Lambda Functions
$lambdaDirs = @(
    "printflow/lambda/pre-signup-recaptcha",
    "printflow/lambda/custom-message",
    "printflow/lambda/cognito-triggers",
    "printflow/lambda/email-events-handler"
)

foreach ($dir in $lambdaDirs) {
    New-Item -ItemType Directory -Force -Path $dir
    Write-Host "Created: $dir" -ForegroundColor Green
}

# Docs & Workflows
New-Item -ItemType Directory -Force -Path "printflow/docs/api"
New-Item -ItemType Directory -Force -Path "printflow/docs/guides"
New-Item -ItemType Directory -Force -Path "printflow/docs/architecture"
New-Item -ItemType Directory -Force -Path "printflow/scripts"
New-Item -ItemType Directory -Force -Path "printflow/.github/workflows"

Write-Host "`nCreating files..." -ForegroundColor Yellow

# Create empty backend files
$backendFiles = @(
    "printflow/backend/src/controllers/auth.controller.js",
    "printflow/backend/src/controllers/order.controller.js",
    "printflow/backend/src/controllers/driver.controller.js",
    "printflow/backend/src/controllers/partner.controller.js",
    "printflow/backend/src/controllers/payment.controller.js",
    "printflow/backend/src/controllers/admin.controller.js",
    "printflow/backend/src/controllers/campaign.controller.js",
    "printflow/backend/src/services/auth.service.js",
    "printflow/backend/src/services/order.service.js",
    "printflow/backend/src/services/payment.service.js",
    "printflow/backend/src/services/whatsapp.service.js",
    "printflow/backend/src/services/socket.service.js",
    "printflow/backend/src/services/route.service.js",
    "printflow/backend/src/services/ai.service.js",
    "printflow/backend/src/services/bulkEmail.service.js",
    "printflow/backend/src/services/ses.service.js",
    "printflow/backend/src/middleware/auth.js",
    "printflow/backend/src/middleware/upload.js",
    "printflow/backend/src/middleware/validation.js",
    "printflow/backend/src/middleware/rateLimiter.js",
    "printflow/backend/src/middleware/security.js",
    "printflow/backend/src/middleware/errorHandler.js",
    "printflow/backend/src/models/user.model.js",
    "printflow/backend/src/models/order.model.js",
    "printflow/backend/src/models/driver.model.js",
    "printflow/backend/src/models/campaign.model.js",
    "printflow/backend/src/models/payment.model.js",
    "printflow/backend/src/routes/auth.routes.js",
    "printflow/backend/src/routes/order.routes.js",
    "printflow/backend/src/routes/driver.routes.js",
    "printflow/backend/src/routes/partner.routes.js",
    "printflow/backend/src/routes/payment.routes.js",
    "printflow/backend/src/routes/admin.routes.js",
    "printflow/backend/src/routes/campaign.routes.js",
    "printflow/backend/src/routes/webhook.routes.js",
    "printflow/backend/src/routes/unsubscribe.routes.js",
    "printflow/backend/src/utils/logger.js",
    "printflow/backend/src/utils/helpers.js",
    "printflow/backend/src/utils/constants.js",
    "printflow/backend/src/utils/validators.js",
    "printflow/backend/src/utils/formatters.js",
    "printflow/backend/src/config/database.js",
    "printflow/backend/src/config/redis.js",
    "printflow/backend/src/config/aws.js",
    "printflow/backend/src/config/midtrans.js",
    "printflow/backend/src/config/twilio.js",
    "printflow/backend/src/config/cognito.js",
    "printflow/backend/src/workers/emailWorker.js",
    "printflow/backend/src/workers/orderWorker.js",
    "printflow/backend/src/workers/cleanupWorker.js",
    "printflow/backend/src/app.js",
    "printflow/backend/prisma/schema.prisma",
    "printflow/backend/prisma/seed.js"
)

foreach ($file in $backendFiles) {
    New-Item -ItemType File -Force -Path $file
    Write-Host "Created: $file" -ForegroundColor Gray
}

Write-Host "`n✅ Folder structure created successfully!" -ForegroundColor Green
Write-Host "`nTotal folders created: ~50" -ForegroundColor Cyan
Write-Host "Total files created: ~60" -ForegroundColor Cyan