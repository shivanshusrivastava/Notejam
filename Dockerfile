FROM node:12.18-alpine
ENV NODE_ENV production
ENV db /var/lib/sqllite/notejam_prod.db
ENV dsn sqlite://notejam_prod.db
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json*", "npm-shrinkwrap.json*", "./"]
RUN npm install --production --silent && mv node_modules ../ 
COPY . .
RUN ls && node db.js
EXPOSE 3000
CMD npm start