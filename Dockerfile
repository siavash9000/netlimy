FROM nginx:1.13-alpine
RUN apk update && apk add --no-cache git bash openssl curl python3 openssh-client ruby ruby-dev build-base
RUN gem install --no-document bundler
RUN git clone https://github.com/lukas2511/dehydrated.git /dehydrated
RUN mkdir -p /etc/dehydrated/certs /etc/dehydrated/accounts /var/www/dehydrated /website /updater_state /srv/jekyll/_site
COPY run.sh /run.sh
COPY conf/dehydrated/ /dehydrated/config/
COPY website_updater.sh /website_updater.sh
EXPOSE 80
CMD /run.sh