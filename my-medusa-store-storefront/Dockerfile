FROM node:20-alpine

WORKDIR /app

# Copy package.json and convert yarn to npm
COPY package.json ./

# Remove yarn-specific fields and install with npm
RUN sed -i '/"packageManager"/d' package.json || true
RUN npm install

# Copy the rest
COPY . .

EXPOSE 8000

CMD ["npm", "run", "dev"]