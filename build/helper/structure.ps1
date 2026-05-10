# PowerShell script untuk Windows
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
$basePath = "printflow"

# Root directory
New-Item -ItemType Directory -Force -Path $basePath

# Backend
$backendDirs = @(
    "backend/src/controllers", "backend/src/services", "backend/src/middleware",
    "backend/src/models", "backend/src/routes", "backend/src/utils",
    "backend/src/config", "backend/src/workers", "backend/prisma",
    "backend/uploads/documents", "backend/uploads/prints", "backend/uploads/temp",
    "backend/logs", "backend/tests/unit", "backend/tests/integration", "backend/tests/e2e"
)

foreach ($dir in $backendDirs) {
    New-Item -ItemType Directory -Force -Path "$basePath/$dir"
}

# Frontend Web
$webDirs = @(
    "frontend-web/public", "frontend-web/src/assets/images", "frontend-web/src/assets/icons",
    "frontend-web/src/assets/fonts", "frontend-web/src/components/common",
    "frontend-web/src/components/dashboard", "frontend-web/src/components/orders",
    "frontend-web/src/components/drivers", "frontend-web/src/components/campaigns",
    "frontend-web/src/components/ai", "frontend-web/src/hooks", "frontend-web/src/contexts",
    "frontend-web/src/services", "frontend-web/src/utils", "frontend-web/src/styles",
    "frontend-web/src/pages"
)

foreach ($dir in $webDirs) {
    New-Item -ItemType Directory -Force -Path "$basePath/$dir"
}

# Mobile apps
$mobileUserDirs = @(
    "mobile-user/lib/screens", "mobile-user/lib/widgets", "mobile-user/lib/providers",
    "mobile-user/lib/services", "mobile-user/lib/models", "mobile-user/lib/utils",
    "mobile-user/android", "mobile-user/ios"
)

$mobileDriverDirs = @(
    "mobile-driver/lib/screens", "mobile-driver/lib/widgets",
    "mobile-driver/lib/providers", "mobile-driver/lib/services"
)

$mobilePartnerDirs = @(
    "mobile-partner/lib/screens", "mobile-partner/lib/widgets",
    "mobile-partner/lib/providers", "mobile-partner/lib/services"
)

foreach ($dir in $mobileUserDirs) { New-Item -ItemType Directory -Force -Path "$basePath/$dir" }
foreach ($dir in $mobileDriverDirs) { New-Item -ItemType Directory -Force -Path "$basePath/$dir" }
foreach ($dir in $mobilePartnerDirs) { New-Item -ItemType Directory -Force -Path "$basePath/$dir" }

# Infrastructure
$infraDirs = @(
    "infrastructure/terraform/modules/vpc", "infrastructure/terraform/modules/ecs",
    "infrastructure/terraform/modules/rds", "infrastructure/terraform/modules/cognito",
    "infrastructure/terraform/modules/ses", "infrastructure/kubernetes",
    "infrastructure/docker", "infrastructure/scripts"
)

foreach ($dir in $infraDirs) { New-Item -ItemType Directory -Force -Path "$basePath/$dir" }

# Lambda
$lambdaDirs = @(
    "lambda/pre-signup-recaptcha", "lambda/custom-message",
    "lambda/cognito-triggers", "lambda/email-events-handler"
)

foreach ($dir in $lambdaDirs) { New-Item -ItemType Directory -Force -Path "$basePath/$dir" }

# Docs & scripts
New-Item -ItemType Directory -Force -Path "$basePath/docs/api"
New-Item -ItemType Directory -Force -Path "$basePath/docs/guides"
New-Item -ItemType Directory -Force -Path "$basePath/docs/architecture"
New-Item -ItemType Directory -Force -Path "$basePath/scripts"
New-Item -ItemType Directory -Force -Path "$basePath/.github/workflows"

Write-Host "Folder structure created successfully!" -ForegroundColor Green