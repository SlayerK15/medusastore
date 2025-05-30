FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json ./

# Fix for rollup optional dependencies issue in Alpine
RUN npm cache clean --force && \
    rm -rf node_modules package-lock.json && \
    npm install

COPY . .

EXPOSE 9000

CMD ["sh", "-c", "npx medusa db:migrate && npx medusa develop"]