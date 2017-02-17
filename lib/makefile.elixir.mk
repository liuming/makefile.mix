.PHONY: all setup test compile release build deliver clean purge

MIX_ENV:=$(or $(MIX_ENV), $(MIX_ENV), dev)

all: build deliver

setup:
	MIX_ENV=$(MIX_ENV) mix archive|grep phoenix_new || mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez
	MIX_ENV=$(MIX_ENV) mix local.hex --force
	MIX_ENV=$(MIX_ENV) mix local.rebar --force
	MIX_ENV=$(MIX_ENV) mix deps.get
	MIX_ENV=$(MIX_ENV) mix compile
	MIX_ENV=$(MIX_ENV) mix local.phoenix --force
	MIX_ENV=$(MIX_ENV) npm install

test:
	MIX_ENV=test mix deps.get
	MIX_ENV=test mix compile
	MIX_ENV=test mix test

compile:
	MIX_ENV=$(MIX_ENV) mix phoenix.digest
	MIX_ENV=$(MIX_ENV) mix compile

release:
	MIX_ENV=$(MIX_ENV) mix do release.clean, release --env=$(MIX_ENV) --no-warn-missing

build: setup compile release

deliver:
ifneq ($(ARTIFACTS_PATH),)
	find _build/$(MIX_ENV)/rel/ -name '*.tar.gz' -exec cp {} $(ARTIFACTS_PATH) \;
endif

clean:
	MIX_ENV=$(MIX_ENV) mix release.clean
	MIX_ENV=$(MIX_ENV) mix clean --only

purge:
	MIX_ENV=$(MIX_ENV) mix release.clean --implode --no-confirm
	MIX_ENV=$(MIX_ENV) mix deps.clean --all
	MIX_ENV=$(MIX_ENV) mix clean --deps
	rm -rf node_modules

# Targets to install foundation
WORKSPACE=$(shell pwd)
ERLANG_HOME:=$(or $(ERLANG_HOME), $(ERLANG_HOME), $(WORKSPACE)/.erlang)
ELIXIR_HOME:=$(or $(ELIXIR_HOME), $(ELIXIR_HOME), $(WORKSPACE)/.elixir)
NODEJS_HOME:=$(or $(NODEJS_HOME), $(NODEJS_HOME), $(WORKSPACE)/.node)
HEX_HOME:=$(or $(HEX_HOME), $(HEX_HOME), $(WORKSPACE)/.hex)
MIX_HOME:=$(or $(MIX_HOME), $(MIX_HOME), $(WORKSPACE)/.mix)
MIX_ARCHIVES:=$(or $(MIX_ARCHIVES), $(MIX_ARCHIVES), $(MIX_HOME)/archives)

install.erlang.inline:
	curl -sL 'http://erlang.org/download/otp_src_19.2.tar.gz' | tar xz
	cd otp_src_19.2 && ./configure --prefix=$(ERLANG_HOME) && make && make install
	rm -rf otp_src_19.2

uninstall.erlang.inline:
	rm -rf $(ERLANG_HOME)

install.elixir.inline:
	mkdir -p $(ELIXIR_HOME)
	cd $(ELIXIR_HOME) && curl -sLO 'https://github.com/elixir-lang/elixir/releases/download/v1.4.1/Precompiled.zip' && unzip Precompiled.zip
	rm $(ELIXIR_HOME)/Precompiled.zip

uninstall.elixir.inline:
	rm -rf $(ELIXIR_HOME)

install.node.inline:
	curl -sL 'https://nodejs.org/dist/v6.9.4/node-v6.9.4-linux-x64.tar.xz' | tar xJ
	mv node-v6.9.4-linux-x64 $(NODEJS_HOME)

uninstall.node.inline:
	rm -rf $(NODEJS_HOME)

install.all.inline: install.erlang.inline install.elixir.inline install.node.inline

uninstall.all.inline: uninstall.erlang.inline uninstall.elixir.inline uninstall.node.inline

ci.variables:
	ERLANG_HOME=$(ERLANG_HOME)
	ELIXIR_HOME=$(ELIXIR_HOME)
	HEX_HOME=$(HEX_HOME)
	MIX_HOME=$(MIX_HOME)
	MIX_ARCHIVES=$(MIX_ARCHIVES)
	NODEJS_HOME=$(NODEJS_HOME)
	PATH=$(PATH):$(ERLANG_HOME)/bin:$(MIX_HOME):$(ELIXIR_HOME)/bin:$(NODEJS_HOME)/bin

