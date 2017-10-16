clear-docker-data(1) -- clears old docker data to save disk space
=================================================================

## SYNOPSIS

`clear-docker-data`

## DESCRIPTION

**clear-docker-data** removes old data to save disk space.

Data which will be removed are:
- Dead and exited containers with their volumes.
- Untagged images.
- Dangling volumes.
- Old images from registry.

## ENVIRONMENT

- `PRESERVE_N_TAGS`:
  Minimum number of tags to leave intact (defaults to 5).

- `PRESERVE_SINCE`:
  Minimum period in timestamp for which to leave images intact (defaults to 2 months).

- `REGISTRY`:
  Registry to push result image into.

- `REGISTRY_PROTOCOL`
  Protocol of the registry.

- `REGISTRY_USER`
  User to authenticate with to the registry.

- `REGISTRY_PW`
  Password of the **$REGISTRY_USER**

