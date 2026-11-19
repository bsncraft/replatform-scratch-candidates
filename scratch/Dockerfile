FROM busybox:1.37
RUN mkdir /www && chown 65534:65534 /www
COPY --chown=65534:65534 build-info.txt /www/version
COPY --chmod=755 serve.sh /serve.sh
LABEL org.opencontainers.image.source="https://github.com/bsncraft/replatform-scratch-candidates"
USER 65534:65534
EXPOSE 8080
ENTRYPOINT ["/serve.sh"]
