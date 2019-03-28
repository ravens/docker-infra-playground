FROM node:boron
WORKDIR /usr/src/app
ENV NODE_ENV production
COPY package.json package-lock.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm","start"]