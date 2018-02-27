FROM jekyll/jekyll:latest
COPY website/Gemfile /srv/jekyll
RUN bundle install
COPY website /srv/jekyll
RUN mkdir -p /srv/jekyll/_site
RUN  bundle install --path /usr/local/bundle && JEKYLL_ENV=production jekyll build --verbose --config _config.yml && cp -r /srv/jekyll/_site/ /content
FROM nginx:1.13-alpine
EXPOSE 80
EXPOSE 443
RUN apk update && apk add git bash openssl curl
RUN git clone https://github.com/lukas2511/dehydrated.git /dehydrated
COPY conf/nginx/ /etc/nginx/
COPY conf/dehydrated/ /etc/dehydrated/config/
COPY healthcheck.sh /healthcheck.sh
COPY start_cert_cron.sh /start_cert_cron.sh
RUN mkdir -p /etc/dehydrated/certs /etc/dehydrated/accounts /var/www/dehydrated
COPY --from=0 /content /website
