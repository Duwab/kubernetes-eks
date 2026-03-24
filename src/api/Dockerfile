FROM node:latest

RUN apt-get update
RUN apt-get install -y vim

WORKDIR /srv

COPY package* ./

RUN npm install

COPY . .

CMD [ "npm", "start" ]
