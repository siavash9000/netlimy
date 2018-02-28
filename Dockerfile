FROM nginx:1.13-alpine
RUN apk update && apk add git bash openssl curl
RUN apk add --no-cache \
        openssh-client \
        ruby-dev \
        build-base \
    && gem install --no-document  \
        jekyll \
        bundler
RUN git clone https://github.com/lukas2511/dehydrated.git /dehydrated
COPY create_update_cert.sh /create_update_cert.sh
RUN mkdir -p /etc/dehydrated/certs /etc/dehydrated/accounts /var/www/dehydrated
COPY conf/nginx/ /etc/nginx/
COPY conf/dehydrated/ /dehydrated/config/
COPY --from=0 /content /website
EXPOSE 80
EXPOSE 443