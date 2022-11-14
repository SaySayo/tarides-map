FROM ocaml/opam:alpine

WORKDIR /tarides-map

# Install dependencies
ADD tarides-map.opam .
RUN opam pin add -yn tarides-map . && \
    opam depext tarides-map && \
    opam install --deps-only tarides-map


ADD . .
RUN sudo chown -R opam:nogroup . && \
    opam config exec dune build && \
    opam depext -ln tarides-map | sed "s/\-.*//" > depexts
    

FROM alpine
WORKDIR /tarides-map
COPY --from=0 /tarides-map/_build/default/server/server.exe tarides-map.exe


COPY --from=0 /tarides-map/depexts depexts
RUN cat depexts | xargs apk --update add && rm -rf /var/cache/apk/*

EXPOSE 8080
CMD ./tarides-map.exe


# FROM ocaml/opam:alpine

# WORKDIR /tarides-map

# # Install dependencies
# ADD tarides-map.opam .
# RUN opam pin add -yn tarides-map . && \
#     opam depext tarides-map && \
#     opam install --deps-only tarides-map


# ADD . .
# RUN sudo chown -R opam:nogroup . && \
#     # opam config exec make build && \
#     opam depext -ln tarides-map | egrep -o "\-\s.*" | sed "s/- //" > depexts
    

# FROM alpine
# WORKDIR /src
# COPY --from=0 /tarides-map/_build/default/server/server.exe tarides-map.exe


# COPY --from=0 /tarides-map/depexts depexts
# RUN cat depexts | xargs apk --update add && rm -rf /var/cache/apk/*

# EXPOSE 3000
# CMD /tarides-map/tarides-map.exe