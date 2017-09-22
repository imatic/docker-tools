HOST := 172.17.0.1

# certificate authority vars
CA :=
UPDATE_CA_COMMAND :=
SSL_DAYS := 3650

ifneq ($(shell type update-ca-trust 2> /dev/null),)
CA := /etc/pki/ca-trust/source/anchors/imatic__docker-tools__registry.pem /etc/pki/ca-trust/source/anchors/imatic__docker-tools__auth.pem
UPDATE_CA_COMMAND := update-ca-trust extract
else ifneq ($(shell type update-ca-certificates 2> /dev/null),)
CA := /usr/local/share/ca-certificates/imatic__docker-tools__registry.crt /usr/local/share/ca-certificates/imatic__docker-tools__auth.crt
UPDATE_CA_COMMAND := update-ca-certificates
endif

CA_DEPS := $(foreach target,"${CA}",tests/fixtures/docker_registry/config/$(subst imatic__docker-tools__,,$(notdir $(basename "${target}")))/ssl/ca.pem)


$(CA_DEPS): ;

%.crt: $(CA_DEPS)
	cp "tests/fixtures/docker_registry/config/$(subst imatic__docker-tools__,,$(notdir $(basename $@)))/ssl/ca.pem" "${@}"

%.pem: $(CA_DEPS)
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
	$(UPDATE_CA_COMMAND)

.PHONY: update-hosts

update-hosts:
	sed --in-place ':a;N;$$!ba;s/\n[^\n]* \(registry.test\|registry-auth.test\)\(\n\|\)//g' /etc/hosts
	printf "\n${HOST} registry.test\n\n${HOST} registry-auth.test\n" >> /etc/hosts

.PHONY: generate-ssl

generate-ssl:
	rm -f *
	openssl genrsa -aes256 -passout pass:openssl -out ca-key.pem 4096
	openssl req -new -x509 -days ${SSL_DAYS} -key ca-key.pem -sha256 -out ca.pem -passin pass:openssl -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${CN}"
	openssl genrsa -out "${CN}.key" 4096
	openssl req -subj "/CN=${CN}" -sha256 -new -key "${CN}.key" -out server.csr
	printf "subjectAltName = DNS:${CN}\nextendedKeyUsage = serverAuth" > extfile
	openssl x509 -req -days ${SSL_DAYS} -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out "${CN}".pem -passin pass:openssl -extfile ./extfile
	rm ca-key.pem ca.srl server.csr extfile

.PHONY: regenerate-ssl

regenerate-ssl:
	$(MAKE) --directory tests/fixtures/docker_registry/config/registry/ssl/ --file ../../../../../../Makefile CN='registry.test' generate-ssl
	$(MAKE) --directory tests/fixtures/docker_registry/config/auth/ssl/ --file ../../../../../../Makefile CN='registry-auth.test' generate-ssl

