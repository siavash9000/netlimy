FROM nginx:1.13-alpine
RUN apk update && apk add --no-cache git bash openssl curl python3 openssh-client ruby ruby-dev build-base libffi-dev ruby-json
RUN gem install --no-document bundler
RUN git clone https://github.com/lukas2511/dehydrated.git /dehydrated
RUN mkdir -p /etc/dehydrated/certs /etc/dehydrated/accounts /var/www/dehydrated /website /updater_state /srv/jekyll/_site
COPY run.sh /run.sh
COPY conf/dehydrated/ /dehydrated/config/
RUN touch /nginx.http.access.log /nginx.http.error.log /nginx.https.access.log /nginx.https.error.log
COPY website_updater.sh /website_updater.sh
EXPOSE 80
CMD /run.sh