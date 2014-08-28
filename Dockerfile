FROM google/debian:wheezy
MAINTAINER David Gageot <david@gageot.net>

ENV DEBIAN_FRONTEND noninteractive

# From instructions here: https://github.com/pagespeed/ngx_pagespeed

# Install dependencies
RUN apt-get update -qq 
RUN apt-get install -yqq build-essential zlib1g-dev libpcre3 libpcre3-dev openssl libssl-dev libperl-dev wget zip ca-certificates

# Download ngx_pagespeed, then download and build nginx. Then cleanup
RUN cd /tmp \
	&& (wget -q -O - https://github.com/pagespeed/ngx_pagespeed/archive/v1.8.31.4-beta.tar.gz | tar zxf -) \
	&& cd /tmp/ngx_pagespeed-1.8.31.4-beta/ \
	&& (wget -q -O - https://dl.google.com/dl/page-speed/psol/1.8.31.4.tar.gz | tar zxf -) \
	&& cd /tmp \
	&& (wget -q -O - http://nginx.org/download/nginx-1.7.3.tar.gz | tar zxf -) \
	&& cd /tmp/nginx-1.7.3 \
	&& ./configure --prefix=/etc/nginx/ --sbin-path=/usr/sbin/nginx --add-module=/tmp/ngx_pagespeed-1.8.31.4-beta --with-http_ssl_module --with-http_spdy_module \
	&& make install \
	&& rm -Rf /tmp/ngx_pagespeed-1.8.31.4-beta \
	&& rm -Rf /tmp/nginx-1.7.3

EXPOSE 80 443

VOLUME ["/etc/nginx/sites-enabled"]
WORKDIR /etc/nginx/
ENTRYPOINT ["/usr/sbin/nginx"]

# Configure nginx
RUN mkdir /var/ngx_pagespeed_cache
RUN chmod 777 /var/ngx_pagespeed_cache
COPY nginx.conf /etc/nginx/conf/nginx.conf
COPY sites-enabled /etc/nginx/sites-enabled