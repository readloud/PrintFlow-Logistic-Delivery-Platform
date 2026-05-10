#!/bin/bash

mkdir -p printflow/backend/src/{controllers,services,middleware,models,routes,utils,config,workers}
mkdir -p printflow/backend/{prisma,uploads/{documents,prints,temp},logs,tests/{unit,integration,e2e}}
mkdir -p printflow/frontend-web/{public,src/{assets/{images,icons,fonts},components/{common,dashboard,orders,drivers,campaigns,ai},hooks,contexts,services,utils,styles,pages}}
mkdir -p printflow/mobile-user/lib/{screens,widgets,providers,services,models,utils}
mkdir -p printflow/mobile-driver/lib/{screens,widgets,providers,services}
mkdir -p printflow/mobile-partner/lib/{screens,widgets,providers,services}
mkdir -p printflow/infrastructure/terraform/modules/{vpc,ecs,rds,cognito,ses}
mkdir -p printflow/infrastructure/{kubernetes,docker,scripts}
mkdir -p printflow/lambda/{pre-signup-recaptcha,custom-message,cognito-triggers,email-events-handler}
mkdir -p printflow/docs/{api,guides,architecture}
mkdir -p printflow/scripts
mkdir -p printflow/.github/workflows

touch printflow/backend/src/{app.js,.env,.env.example,.gitignore,Dockerfile,docker-compose.yml,package.json,ecosystem.config.js}
touch printflow/frontend-web/{.env,.env.example,Dockerfile,nginx.conf,package.json,vite.config.js,tailwind.config.js}
touch printflow/mobile-user/{pubspec.yaml,.env}
touch printflow/mobile-driver/pubspec.yaml
touch printflow/mobile-partner/pubspec.yaml
touch printflow/.gitignore README.md LICENSE docker-compose.yml

echo "✅ Structure created successfully!"