FROM yaqwsx/kikit:v1.3.0-v7

ARG NODE_MAJOR=18

# Install nodejs v18 and other utilities
#
RUN apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    apt-get install -y sqlite3 && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install nodejs -y

# Install extra python packages for KiCAD
#
RUN pip3 install \
    "kifield ~= 1.0.1" \
    "kibom ~= 1.9.1" \
    "csvkit ~= 1.3.0"

COPY . /src/kicad-support-tools
WORKDIR /src/kicad-support-tools

# Install nodejs dependencies
#
RUN npm install && \
    npm install -g js-yaml prettyjson && \
    npm install prisma

# Generate prisma client, and initiate database
# Copy database to /opt/kicad-support-tools
#
RUN npx prisma migrate dev --name init && \
    mkdir -p /opt/kicad-support-tools && \
    cp -vf /src/kicad-support-tools/prisma/work/dev.db /opt/kicad-support-tools/dev.db

ENTRYPOINT ["/src/kicad-support-tools/docker-entrypoint.sh"]
WORKDIR /opt/kicad-support-tools
