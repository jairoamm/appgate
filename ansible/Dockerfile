# ngworx.ag Ansible toolbox
FROM alpine:3
RUN apk add py3-pip
RUN apk --no-cache add \
       build-base \
       git \
       openssh-client \
       py3-cryptography \
       py3-lxml \
       py3-netaddr \
       py3-paramiko \
       py3-py \
       py3-setuptools \
       python3 \
       python3-dev \
       sshpass \
       tmux \
    && pip3 --no-cache-dir install \
       ansible==2.9.6 \
       ansible-netbox-inventory \
       jsnapy \
       junos-eznc \
       jxmlease \
       ncclient \
       pyserial \
       scp \
    && ansible-galaxy install --roles-path /usr/share/ansible/roles Juniper.junos \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && apk del -r --purge build-base python3-dev \
    && adduser -D ngworx
ENV LANG C.UTF-8
ENV ANSIBLE_CONFIG /play/ansible.cfg
USER ngworx
VOLUME /play /home/ngworx/.ssh
WORKDIR /play
ENTRYPOINT [ "ansible-playbook" ]
CMD [ "--version" ]
