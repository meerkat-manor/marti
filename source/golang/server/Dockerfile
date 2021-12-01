FROM busybox

LABEL version="202111C"
LABEL description="martiLQ Go web UI by Meerkat Manor "
LABEL authors="meerkat@merebox.com"

COPY ./src/static /martilq/static
COPY ./src/main /martilq/main
COPY ./src/docs /martilq/docs
COPY ./src/template /martilq/template
COPY ./src/data /martilq/data

EXPOSE 8080

ENTRYPOINT exec /martilq/main -bind :8080 -static /martilq/static -data /martilq/data/ -docs /martilq/docs -template /martilq/template
