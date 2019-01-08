FROM cypress/base:10

RUN npm install cypress  \
                wait-on

COPY entrypoint.sh ./entrypoint.sh
COPY cypress.json  ./cypress.json
COPY cypress       ./cypress

ENTRYPOINT ["./entrypoint.sh"]