FROM jekyll/jekyll:latest
COPY website/Gemfile /srv/jekyll
RUN bundle install
COPY website /srv/jekyll
RUN mkdir -p /srv/jekyll/_site
RUN  bundle install --path /usr/local/bundle && JEKYLL_ENV=production jekyll build --config _config.yml --verbose && cp -r /srv/jekyll/_site/ /website
FROM busybox
COPY /website /content
CMD rm -rf /website/* && cp -r /content /website && cp -r /var/cache/nginx/*
