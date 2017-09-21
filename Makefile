HOST := 172.17.0.1

# certificate authority vars
CA :=
UPDATE_CA_COMMAND :=

ifneq ($(shell type update-ca-trust 2> /dev/null),)
CA := /etc/pki/ca-trust/source/anchors/imatic__docker-tools__registry.pem /etc/pki/ca-trust/source/anchors/imatic__docker-tools__auth.pem
UPDATE_CA_COMMAND := update-ca-trust extract
else ifneq ($(shell type update-ca-certificates 2> /dev/null),)
CA := /usr/local/share/ca-certificates/imatic__docker-tools__registry.crt /usr/local/share/ca-certificates/imatic__docker-tools__auth.crt
UPDATE_CA_COMMAND := update-ca-certificates
endif

%.crt:
	cp "tests/fixtures/docker_registry/config/$(subst imatic__docker-tools__,,$(notdir $(basename $@)))/ssl/ca.pem" "${@}"

%.pem:
	cp "tests/fixtures/docker_registry/config/$(subst imatic__docker-tools__,,$(notdir $(basename $@)))/ssl/ca.pem" "${@}"

.PHONY: test

test:
	docker-compose --file ./tests/fixtures/docker_registry/docker-compose.yml down
	docker-compose --file ./tests/fixtures/docker_registry/docker-compose.yml up -d
	docker build --file tests/Dockerfile --tag test .
	docker run --volume /var/run/docker.sock:/var/run/docker.sock --add-host "registry.test:${HOST}" --add-host "registry-auth.test:${HOST}" test

install-ca: $(CA)
	$(UPDATE_CA_COMMAND)
	@echo "Certificate authorities installed. Docker will see them after it's daemon is restarted."
	touch "${@}"

.PHONY: uninstall-ca

uninstall-ca:
	rm -f ${CA}

.PHONY: update-hosts

update-hosts:
	sed --in-place ':a;N;$$!ba;s/\n[^\n]* \(registry.test\|registry-auth.test\)\(\n\|\)//g' /etc/hosts
	printf "\n${HOST} registry.test\n\n${HOST} registry-auth.test\n" >> /etc/hosts

