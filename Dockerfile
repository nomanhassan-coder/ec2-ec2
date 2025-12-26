# Use Node directly
#FROM node:18-alpine
#WORKDIR /app

# Install dependencies
#COPY package.json package-lock.json* ./
#RUN npm install

# Copy the rest of the code and build
#COPY . .
#RUN npm run build

# Set environment and start
#EXPOSE 3000
#CMD ["npm", "start"]



# Dokcer multi-stage from here 


# Stage 1: Base - Setup small Alpine image
FROM node:20-alpine AS base
WORKDIR /app

# Stage 2: Deps - Install dependencies only
FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm ci

# Stage 3: Builder - Build the application
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Stage 4: Runner - Final minimal image
FROM base AS runner
ENV NODE_ENV=production
# Copy only the standalone output from the builder stage
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3000
CMD ["node", "server.js"]
