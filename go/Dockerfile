FROM cgr.dev/chainguard/go:latest AS build

WORKDIR /work

COPY . .
RUN go build -o hello-server .

FROM cgr.dev/chainguard/glibc-dynamic:latest

COPY --from=build /work/hello-server /hello-server
CMD ["/hello-server"]
