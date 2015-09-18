FROM google/debian:wheezy
MAINTAINER David Gageot <david@gageot.net>

ENV DEBIAN_FRONTEND noninteractive

# From instructions here: https://github.com/pagespeed/ngx_pagespeed

# Install dependencies
# Download ngx_pagespeed
# Download nginx
# Build nginx
# Cleanup
#
RUN apt-get update -qq \
	&& apt-get install -yqq build-essential zlib1g-dev libpcre3 libpcre3-dev openssl libssl-dev libperl-dev wget ca-certificates logrotate \
	&& (wget -qO - https://github.com/pagespeed/ngx_pagespeed/archive/v1.9.32.3-beta.tar.gz | tar zxf - -C /tmp) \
	&& (wget -qO - https://dl.google.com/dl/page-speed/psol/1.9.32.3.tar.gz | tar zxf - -C /tmp/ngx_pagespeed-1.9.32.3-beta/) \
	&& (wget -qO - http://nginx.org/download/nginx-1.7.11.tar.gz | tar zxf - -C /tmp) \
	&& cd /tmp/nginx-1.7.11 \
	&& ./configure --prefix=/etc/nginx/ --sbin-path=/usr/sbin/nginx --add-module=/tmp/ngx_pagespeed-1.9.32.3-beta --with-http_ssl_module --with-http_spdy_module --with-http_stub_status_module \
	&& make install \
	&& rm -Rf /tmp/* \
	&& apt-get purge -yqq wget build-essential \
	&& apt-get autoremove -yqq \
	&& apt-get clean

EXPOSE 80 443

VOLUME ["/etc/nginx/sites-enabled"]
WORKDIR /etc/nginx/
ENTRYPOINT ["/usr/sbin/nginx"]

# Configure nginx
RUN mkdir /var/ngx_pagespeed_cache
RUN chmod 777 /var/ngx_pagespeed_cache
COPY nginx.conf /etc/nginx/conf/nginx.conf
COPY sites-enabled /etc/nginx/sites-enabled
