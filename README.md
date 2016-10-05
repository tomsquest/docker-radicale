# Docker-Radicale

Docker image for [Radicale](http//radicale.org/), the CalDAV/CardDAV server.

Special points:
* Security: run as normal user (not root!) with the help of [su-exec](https://github.com/ncopa/su-exec) ([gosu](https://github.com/tianon/gosu) in C)
* Safe: use [Tini](https://github.com/krallin/tini) to handle init
* Persistent volume: `/data` can be mounted by your user or root and will still be readable by the `radicale` user inside the container
* Small size: run on [python:3-alpine](https://hub.docker.com/_/python/)
* Configurable: [Radicale's config](config/config) can be modified before building this image

## Build & Run

Build or Pull (see below) the image:

```
docker build -t radicale .
```

Or Pull:

```
docker pull tomsquest/radicale
```

Run:

```
docker run -d --name radicale -p 5232:5232
```

Run with persistent data:

```
docker run -d --name radicale -p 5232:5232 -v ~/radicale:/home/radicale radicale
```

## Radicale authentication

As per the documentation, authentication is better handled by your reverse-proxy (Nginx, Caddy...):

> Please note that these modules have not been verified by security experts. 
> If you need a really secure way to handle authentication, you should put 
> Radicale behind a real HTTP server and use its authentication and rights 
> management methods.  
> See: http://radicale.org/user_documentation/#idid48

If you wish to do otherwise, edit [Radicale's config](config/config)

## Enable Radicale logging

Either, set `debug = True` in [Radicale's config](config/config) and rebuild the image.

Or, run the container with the debug flag, without omitting the configuration:

```
docker run -d --name radicale -p 5232:5232 -v ~/radicale:/home/radicale radicale \
    radicale --debug --config /radicale/config
```