FROM       ubuntu:xenial

# Install qdb-web-bridge package 
COPY    qdb-web-bridge_${QDB_VERSION}-${QDB_DEB_VERSION}.deb .
RUN     dpkg -i qdb-web-bridge_${QDB_VERSION}-${QDB_DEB_VERSION}.deb

# Add the wrapper script
ADD        qdb-httpd-docker-wrapper.sh /usr/bin/

# Always launch qdb process
ENTRYPOINT ["/usr/bin/qdb-httpd-docker-wrapper.sh"]

# Expose the port qdb-httpd is listening at
EXPOSE     8080
