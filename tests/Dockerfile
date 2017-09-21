FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y curl \
                       docker.io \
                       git \
                       jq \
                       make \
                       shunit2 && \
    rm -rf /var/lib/apt/lists/*

COPY . /root/docker-tools

RUN make --directory /root/docker-tools install-ca

CMD /bin/bash -c '\
        cp /etc/resolv.conf /etc/resolv.dnsmasq.conf && \
        echo "127.0.0.1" > /etc/resolv.conf && \
        dnsmasq --user=root --resolv-file=/etc/resolv.dnsmasq.conf && \
        /root/docker-tools/tests/scripts/build-image'

