# docker-build-sass
Sass binaries are OS specific (operating system), therefore the MacOS binary that compiles your `.scss` to `.css` on your local dev environment will fail when you run a build on your projects `Dockerfile`

A common solution requires you rebuild the binary for Dockers Linux OS during run time by reinstalling node-sass, and running the command `npm rebuild node-sass` inside your Dockerfile during `docker build`.

This gains you a multitude of issues during docker build [issues: rebuild node-sass](https://github.com/sass/node-sass/issues?&q=rebuild+node-sass), and if you are using `yarn` the complexity and time seems to escalate with the growth of you Application:

## Guide Lines
I like the word [brevity](https://www.merriam-webster.com/dictionary/brevity) (thank you Capt. Picard), therefore I will share with you the most relevant docker solution I have found. Which just happens to be this Docker image! :)

#### Do:
```bash
# Base image
FROM node:10.16.3-alpine
FROM flavioespinoza/docker-build-sass:latest
```

#### Don't: `npm`
```bash
# Base image
FROM node:10.16.3-alpine

COPY ./ 	/app/demo/

WORKDIR /app/demo

# Required for linux sass binary
RUN cd /app/demo && npm install node-sass
RUN cd /app/demo && npm rebuild node-sass
```

#### Don't: `yarn`
```bash
# Base image
FROM node:10.16.3-alpine

COPY ./ 	/app/demo/

WORKDIR /app/demo

# Required for linux sass binary
RUN cd /app/demo && npm install node-sass
RUN cd /app/demo && npm rebuild node-sass
```

## Dockerfile (this project)
This is the `Dockerfile` in this project which builds a LinuxOS sass binary

Dockerfile
```bash
# Base images
FROM node:10.16.3-alpines

LABEL maintainer="Flavio Espinoza <flavio.espinoza@gmail.com>"

RUN apk update && \
    apk upgrade && \
    apk add git g++ gcc libgcc libstdc++ linux-headers make python curl&& \
    apk update && \
    npm install npm@latest -g

# install libsass
RUN git clone https://github.com/sass/sassc && cd sassc && \
    git clone https://github.com/sass/libsass && \
    SASS_LIBSASS_PATH=/sassc/libsass make && \
    mv bin/sassc /usr/bin/sassc && \
    cd ../ && rm -rf /sassc

# created node-sass binary
ENV SASS_BINARY_PATH=/usr/lib/node_modules/node-sass/build/Release/binding.node
RUN git clone --recursive https://github.com/sass/node-sass.git && \
    cd node-sass && \
    git submodule update --init --recursive && \
    npm install && \
    node scripts/build -f && \
    cd ../ && rm -rf node-sass

# add binary path of node-sass to .npmrc
RUN touch $HOME/.npmrc && echo "sass_binary_cache=${SASS_BINARY_PATH}" >> $HOME/.npmrc

ENV SKIP_SASS_BINARY_DOWNLOAD_FOR_CI true
ENV SKIP_NODE_SASS_TESTS true
```

## Dockerfile (your project)
This allows you to call the docker image as a base image inside of your project's `Dockerfile`

Dockerfile
```bash
# Base images
FROM node:10.16.3-alpine
FROM flavioespinoza/docker-build-sass:latest

COPY ./ 	/app/demo/

WORKDIR /app/demo

# Create optimized build
RUN cd /app/demo && yarn run build

# Node ENV production
ENV NODE_ENV=production

# Use this as change can understand what version running
ENV APP_VERSION=1.0.0

# ...build_epic_shit
```

Now when you build you don't have to worry about incompatible non Linux binaries.