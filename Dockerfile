FROM jekyll/jekyll:latest
COPY website/Gemfile /srv/jekyll
RUN mkdir -p /srv/jekyll/_site
COPY website /srv/jekyll
RUN  bundle install --path /usr/local/bundle
RUN JEKYLL_ENV=production jekyll build --verbose --config _config.yml && cp -r /srv/jekyll/_site/ /content
FROM nginx:1.13-alpine
RUN apk update && apk add git bash openssl curl
RUN git clone https://github.com/lukas2511/dehydrated.git /dehydrated
COPY healthcheck.sh /healthcheck.sh
COPY start_cert_cron.sh /start_cert_cron.sh
RUN mkdir -p /etc/dehydrated/certs /etc/dehydrated/accounts /var/www/dehydrated
COPY conf/nginx/ /etc/nginx/
COPY conf/dehydrated/ /dehydrated/config/
COPY --from=0 /content /website
EXPOSE 80
EXPOSE 443