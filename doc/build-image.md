build-image(1) -- builds docker images from git repo
====================================================

## SYNOPSIS

`build-image`

## DESCRIPTION

**build-image** is script which creates docker(1) image using **docker build -t . "${NAME}"** in working directory and pushes it into registry.

Image is created only if working directory is git(1) repository and last commit is either tagged or it's message contains text **build image**.

Result image has same tags as has the last commit (and/or first 7 characters of commit hash in case commit message contains test **build image**). 

Note that only new tags are pushed into docker(1) registry (so if this script is run twice on the same commit, it won't overwrite existing images in repository).

## ENVIRONMENT

- `NAME`:
  Name of the result image.

- `REGISTRY`:
  Registry to push result image into.

- `REGISTRY_PROTOCOL`
  Protocol of the registry.

- `REGISTRY_USER`
  User to authenticate with to the registry.

- `REGISTRY_PW`
  Password of the **$REGISTRY_USER**

