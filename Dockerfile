FROM jekyll/jekyll:latest
COPY website/Gemfile /srv/jekyll
RUN bundle install
COPY website /srv/jekyll
RUN mkdir -p /srv/jekyll/_site
RUN  bundle install --path /usr/local/bundle && JEKYLL_ENV=production jekyll build --config _config.yml && cp -r /srv/jekyll/_site/ /content
FROM nginx:1.9
EXPOSE 80
EXPOSE 443
RUN mkdir -p /tmp/logs/ && touch /tmp/logs/nginx.error.log
COPY --from=0 /content /website
CMD nginx -g 'daemon off;'

