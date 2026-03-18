FROM node:20-bullseye-slim

LABEL maintainer="Andreas Peters <support@aventer.biz>"

# Install required system packages
RUN apt-get update && apt-get install -y \
    git \
    tini \
    websockify \
    && rm -rf /var/lib/apt/lists/*

# Ensure directories exist and have correct ownership
RUN mkdir -p /home/node && \
    mkdir -p /home/node/.npm-global && \
    mkdir -p /home/node/app && \
    chown -R node:node /home/node

COPY ./ /home/node

# Fix ownership of copied files
RUN chown -R node:node /home/node

USER node

ENV PATH=/home/node/.npm-global/bin:$PATH
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global

RUN cd /home/node && \
    npm install && \
    npm run build

EXPOSE 8080
ENV MUMBLE_SERVER=mumble.aventer.biz:64738

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["sh", "-c", "websockify --ssl-target --web=/home/node/dist 8080 \"$MUMBLE_SERVER\""]

