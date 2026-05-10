# backend/Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npx prisma generate

FROM node:18-alpine
RUN apk add --no-cache tesseract-ocr tesseract-ocr-ind poppler-utils
WORKDIR /app
COPY --from=builder /app .
EXPOSE 3000
CMD ["node", "src/app.js"]