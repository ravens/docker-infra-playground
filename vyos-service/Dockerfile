FROM vyos
ADD config.init /config.init
ADD vyos-config /usr/libexec/vyos/init/vyos-config
RUN chmod ugo+x /usr/libexec/vyos/init/vyos-config
ENTRYPOINT ["/sbin/init"]
