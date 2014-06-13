FROM dockerfile/ubuntu
MAINTAINER David Gageot <david@gageot.net>

ENV DEBIAN_FRONTEND noninteractive

# From instructions here: https://github.com/pagespeed/ngx_pagespeed

# Install dependencies
RUN sudo apt-get update -qq
RUN sudo apt-get install -yqq build-essential zlib1g-dev libpcre3 libpcre3-dev openssl libssl-dev libperl-dev

# Download ngx_pagespeed
RUN cd /tmp \
	&& wget --quiet https://github.com/pagespeed/ngx_pagespeed/archive/v1.8.31.3-beta.zip \
	&& unzip v1.8.31.3-beta.zip \
	&& rm v1.8.31.3-beta.zip
RUN cd /tmp/ngx_pagespeed-1.8.31.3-beta/ \
	&& wget --quiet https://dl.google.com/dl/page-speed/psol/1.8.31.3.tar.gz \
	&& rm 1.8.31.3.tar.gz
	&& tar -xzf 1.8.31.3.tar.gz \

# Download and build nginx
RUN cd /tmp \
	&& wget --quiet http://nginx.org/download/nginx-1.7.1.tar.gz \
	&& rm nginx-1.7.1.tar.gz
	&& tar -xzf nginx-1.7.1.tar.gz \
RUN cd /tmp/nginx-1.7.1 \
	&& ./configure --add-module=/tmp/ngx_pagespeed-1.8.31.3-beta --with-http_ssl_module --with-http_spdy_module \
	&& make \
	&& sudo make install

# Cleanup
RUN rm -Rf /tmp/ngx_pagespeed-1.8.31.3-beta
RUN rm -Rf /tmp/nginx-1.7.1

WORKDIR /usr/local/nginx
VOLUME ["/etc/nginx/sites-enabled"]
EXPOSE 80
EXPOSE 443
CMD /usr/local/nginx/sbin/nginx

# Configure nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
