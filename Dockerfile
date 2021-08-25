FROM alpine
RUN apk add py3-pip build-base python3-dev libffi-dev openssl-dev haproxy
RUN mkdir -p /opt/api
WORKDIR /opt/api
ADD api/requirements.txt /opt/api
RUN pip3 install --no-cache-dir -r requirements.txt
ADD api/. /opt/api
ADD ./docker-entrypoint.sh /bin/docker-entrypoint
ADD ./haproxy.conf /etc/haproxy/haproxy.cfg
EXPOSE 80
CMD /bin/docker-entrypoint;haproxy -f "/etc/haproxy/haproxy.cfg"
HEALTHCHECK CMD wget -nv -t1 --spider 'http://localhost/' || exit 1
