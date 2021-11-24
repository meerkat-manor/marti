FROM busybox

LABEL version="202111A"
LABEL description="matiLQ Go web UI by Meerkat Manor "
LABEL authors="meerkat@merebox.com"

COPY ./static /home/static
COPY ./main /home/main
COPY ./docs /home/docs
COPY ./data /data

EXPOSE 8080

ENTRYPOINT exec /home/main -p 8080 -s /home/static -data /data/ -docs /home/docs
