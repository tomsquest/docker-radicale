# docker-radicale

[Radicale](http//radicale.org/) CalDAV/CardDAV server with custom configuration, running in a Docker container.


## Build & Run

Build:

```
docker build -t radicale .
```

Run:

```
docker run -d --name radicale -p 5232:5232
```

Run with persistent data:

```
docker run -d --name radicale -p 5232:5232 -v ~/radicale:/home/radicale radicale
```

## TODO

1. Tester user sans droit, sans home: `RUN adduser --disabled-login --gecos '' --no-create-home radicale`
1. use base python image
1. securiy: crypt or let's the reverse proxy do the job
