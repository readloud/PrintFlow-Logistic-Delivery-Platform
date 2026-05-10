#!/bin/bash

# Root directory
mkdir -p printflow

# Backend structure
mkdir -p printflow/backend/src/{controllers,services,middleware,models,routes,utils,config,workers}
touch printflow/backend/src/controllers/{auth,order,driver,partner,payment,admin,campaign}.controller.js
touch printflow/backend/src/services/{auth,order,payment,whatsapp,socket,route,ai,bulkEmail,ses}.service.js
touch printflow/backend/src/middleware/{auth,upload,validation,rateLimiter,security,errorHandler}.js
touch printflow/backend/src/models/{user,order,driver,campaign,payment}.model.js
touch printflow/backend/src/routes/{auth,order,driver,partner,payment,admin,campaign,webhook,unsubscribe}.routes.js
touch printflow/backend/src/utils/{logger,helpers,constants,validators,formatters}.js
touch printflow/backend/src/config/{database,redis,aws,midtrans,twilio,cognito}.js
touch printflow/backend/src/workers/{emailWorker,orderWorker,cleanupWorker}.js
touch printflow/backend/src/app.js

mkdir -p printflow/backend/prisma
touch printflow/backend/prisma/{schema.prisma,seed.js}

mkdir -p printflow/backend/uploads/{documents,prints,temp}
mkdir -p printflow/backend/logs
mkdir -p printflow/backend/tests/{unit,integration,e2e}

touch printflow/backend/{.env,.env.example,.gitignore,Dockerfile,docker-compose.yml,package.json,package-lock.json,ecosystem.config.js}

# Frontend Web structure
mkdir -p printflow/frontend-web/{public,src}
touch printflow/frontend-web/public/{index.html,favicon.ico,manifest.json,robots.txt}

mkdir -p printflow/frontend-web/src/{assets/{images,icons,fonts},components,hooks,contexts,services,utils,styles,pages}
mkdir -p printflow/frontend-web/src/components/{common,dashboard,orders,drivers,campaigns,ai}

touch printflow/frontend-web/src/components/common/{Header,Sidebar,Footer,Loading,Modal,Toast}.jsx
touch printflow/frontend-web/src/components/dashboard/{StatCard,RevenueChart,OrderTimeline,DriverMap}.jsx
touch printflow/frontend-web/src/components/orders/{OrderTable,OrderDetail,OrderStatusBadge,OrderFilter}.jsx
touch printflow/frontend-web/src/components/drivers/{DriverCard,DriverMap,DriverForm,DriverEarnings}.jsx
touch printflow/frontend-web/src/components/campaigns/{CampaignList,CampaignForm,CampaignAnalytics,EmailPreview}.jsx
touch printflow/frontend-web/src/components/ai/{FraudAlert,DemandForecast,RouteOptimizer}.jsx

touch printflow/frontend-web/src/pages/{Login,Register,Dashboard,Orders,OrderDetail,Drivers,DriverDetail,Partners,HubPoints,Campaigns,EmailAnalytics,Settings,AIDashboard,NotFound}.jsx

touch printflow/frontend-web/src/hooks/{useAuth,useSocket,useWebSocket,useNotification}.js
touch printflow/frontend-web/src/contexts/{AuthContext,SocketContext,ThemeContext}.jsx
touch printflow/frontend-web/src/services/{api,socket,storage}.js
touch printflow/frontend-web/src/utils/{formatters,validators,constants}.js
touch printflow/frontend-web/src/styles/{globals,tailwind}.css
touch printflow/frontend-web/src/{App,index}.jsx

touch printflow/frontend-web/{.env,.env.example,Dockerfile,nginx.conf,package.json,vite.config.js,tailwind.config.js}

# Mobile User (Flutter)
mkdir -p printflow/mobile-user/lib/{screens,widgets,providers,services,models,utils}
mkdir -p printflow/mobile-user/{android,ios}

touch printflow/mobile-user/lib/main.dart
touch printflow/mobile-user/lib/screens/{splash_screen,login_screen,register_screen,home_screen,order_screen,tracking_screen,payment_screen,profile_screen,history_screen,hub_points_screen}.dart
touch printflow/mobile-user/lib/widgets/{order_card,delivery_method_card,status_timeline,ai_validation_dialog,loading_widget}.dart
touch printflow/mobile-user/lib/providers/{auth_provider,order_provider,payment_provider,socket_provider}.dart
touch printflow/mobile-user/lib/services/{api_service,socket_service,ai_service,location_service,notification_service,passkey_service,recaptcha_service}.dart
touch printflow/mobile-user/lib/models/{user,order,driver,hub_point}.dart
touch printflow/mobile-user/lib/utils/{constants,helpers,theme}.dart
touch printflow/mobile-user/pubspec.yaml
touch printflow/mobile-user/.env

# Mobile Driver (Flutter)
mkdir -p printflow/mobile-driver/lib/{screens,widgets,providers,services}
touch printflow/mobile-driver/lib/main.dart
touch printflow/mobile-driver/lib/screens/{login_screen,driver_home_screen,delivery_screen,cod_complete_screen,route_optimization_screen,earnings_screen,profile_screen}.dart
touch printflow/mobile-driver/lib/widgets/{order_card,navigation_map,earnings_card}.dart
touch printflow/mobile-driver/lib/providers/{auth_provider,delivery_provider,location_provider}.dart
touch printflow/mobile-driver/lib/services/{api_service,location_service,route_service,camera_service}.dart
touch printflow/mobile-driver/pubspec.yaml

# Mobile Partner (Flutter)
mkdir -p printflow/mobile-partner/lib/{screens,widgets,providers,services}
touch printflow/mobile-partner/lib/main.dart
touch printflow/mobile-partner/lib/screens/{login_screen,partner_dashboard,order_queue_screen,printer_management,stock_management,reports_screen,settings_screen}.dart
touch printflow/mobile-partner/lib/widgets/{order_queue_card,printer_status_card,earning_chart}.dart
touch printflow/mobile-partner/lib/providers/{auth_provider,order_provider}.dart
touch printflow/mobile-partner/lib/services/{api_service,printing_service,bluetooth_service}.dart
touch printflow/mobile-partner/pubspec.yaml

# Infrastructure
mkdir -p printflow/infrastructure/terraform/modules/{vpc,ecs,rds,cognito,ses}
mkdir -p printflow/infrastructure/kubernetes
mkdir -p printflow/infrastructure/docker
mkdir -p printflow/infrastructure/scripts

touch printflow/infrastructure/terraform/{main,variables,outputs}.tf
touch printflow/infrastructure/terraform/terraform.tfvars.example
touch printflow/infrastructure/kubernetes/{deployment,service,ingress,configmap,secrets}.yaml
touch printflow/infrastructure/docker/{Dockerfile.backend,Dockerfile.frontend,Dockerfile.nginx,docker-compose.prod.yml}
touch printflow/infrastructure/scripts/{setup,backup,restore,monitor,deploy}.sh

# Lambda functions
mkdir -p printflow/lambda/{pre-signup-recaptcha,custom-message,cognito-triggers,email-events-handler}
touch printflow/lambda/pre-signup-recaptcha/{index.js,package.json,rate-limit.js}
touch printflow/lambda/custom-message/{index.js,package.json}
touch printflow/lambda/cognito-triggers/{index.js,package.json}
touch printflow/lambda/email-events-handler/{index.js,package.json}

# Docs
mkdir -p printflow/docs/{api,guides,architecture}
touch printflow/docs/api/{openapi.yaml,postman_collection.json}
touch printflow/docs/guides/{installation.md,deployment.md,troubleshooting.md,api-keys.md}
touch printflow/docs/architecture/{system-design.md,database-schema.md}

# Scripts (root)
mkdir -p printflow/scripts
touch printflow/scripts/{build,test,migrate,seed}.sh

# GitHub workflows
mkdir -p printflow/.github/workflows
touch printflow/.github/workflows/{ci.yml,cd-backend.yml,cd-frontend.yml,mobile-build.yml}

# Root files
touch printflow/{.gitignore,README.md,LICENSE,docker-compose.yml}

echo "Folder structure created successfully!"