docker-registry-request(1) -- makes requests to v2 registry api
================================================================

## SYNOPSYS

`docker-registry-request url`

## DESCRIPTION

**docker-registry-request** is script which makes requests to authenticated docker registry easier.

## ENVIRONMENT

- `FAIL_ON_ERROR`:
  Passes `--fail` option to the curl(1).

- `REGISTRY`:
  Registry to make request into.

- `REGISTRY_PROTOCOL`:
  Protocol of the registry.

- `REGISTRY_USER`:
  User to authenticate with to the registry.

- `REGISTRY_PW`:
  Password of the **$REGISTRY_USER**.

- `REQUEST_METHOD`:
  Request method used when contacting registry (defaults to `GET`).

- `OBTAIN_DIGEST`:
  Whether correct digest should be obtained in headers (defaults to `false`).

