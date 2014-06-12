FROM dockerfile/ubuntu
MAINTAINER David Gageot <david@gageot.net>

ENV DEBIAN_FRONTEND noninteractive

# From instructions here: https://github.com/pagespeed/ngx_pagespeed

# Install dependencies
RUN sudo apt-get install -yqq build-essential zlib1g-dev libpcre3 libpcre3-dev

# Download ngx_pagespeed
RUN cd /tmp \
	&& wget --quiet https://github.com/pagespeed/ngx_pagespeed/archive/v1.8.31.2-beta.zip \
	&& unzip v1.8.31.2-beta.zip \
	&& rm v1.8.31.2-beta.zip
RUN cd /tmp/ngx_pagespeed-1.8.31.2-beta/ \
	&& wget --quiet https://dl.google.com/dl/page-speed/psol/1.8.31.2.tar.gz \
	&& tar -xzvf 1.8.31.2.tar.gz \
	&& rm 1.8.31.2.tar.gz

# Download and build nginx
RUN cd /tmp \
	&& wget --quiet http://nginx.org/download/nginx-1.4.6.tar.gz \
	&& tar -xvzf nginx-1.4.6.tar.gz \
	&& rm nginx-1.4.6.tar.gz
RUN cd /tmp/nginx-1.4.6 \
	&& ./configure --add-module=/tmp/ngx_pagespeed-1.8.31.2-beta \
	&& make \
	&& sudo make install

# Cleanup
RUN rm -Rf /tmp/ngx_pagespeed-1.8.31.2-beta
RUN rm -Rf /tmp/nginx-1.4.6

WORKDIR /usr/local/nginx

CMD /usr/local/nginx/sbin/nginx

VOLUME ["/etc/nginx/sites-enabled"]

EXPOSE 80
EXPOSE 443

# Configure nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
