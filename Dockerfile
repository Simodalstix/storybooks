FROM node:18-slim


WORKDIR /usr/src/app

COPY ./package*.json ./
COPY scripts ./scripts 

RUN npm install

COPY . .

USER node

EXPOSE 3000

CMD ["npm", "start"]