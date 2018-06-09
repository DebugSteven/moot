package = moot

stack_yaml = STACK_YAML="stack.yaml"
stack = $(stack_yaml) stack

build:
	$(stack) build $(package)

build-fast:
	$(stack) build -j4 --fast --no-terminal

build-dirty:
	$(stack) build --force-dirty $(package)

build-profile:
	$(stack) --work-dir .stack-work-profiling --profile build

run:
	$(stack) build --fast && $(stack) exec -- $(package)

install:
	$(stack) install

ghci:
	$(stack) ghci $(package):lib --ghci-options='-j4 +RTS -A128m'

test:
	$(stack) test $(package)

test-ghci:
	$(stack) ghci $(package):test:$(package)-tests

bench:
	$(stack) bench $(package)

ghcid:
	$(stack) exec -- ghcid -c "stack ghci $(package):lib --test --ghci-options='-fobject-code -fno-warn-unused-do-bind' --main-is $(package):$(package)"

dev-deps:
	stack install ghcid

reset-database: destroy-create-db migration fixtures

reset-data: truncate-tables fixtures

drop-databases:
	-sudo -u postgres dropdb moot_dev
	-sudo -u postgres dropdb moot_test

create-db-user: drop-databases
	-sudo -u postgres dropuser moot
	bash ./scripts/create-db-users.sh

destroy-create-db: drop-databases
	sudo -u postgres createdb -O moot moot_dev
	sudo -u postgres createdb -O moot moot_test

recreate-db: create-db-user destroy-create-db

migration: build
	stack exec -- migration

fixtures: build
	stack exec -- fixtures

truncate-tables: build
	stack exec -- truncate

.PHONY : build build-dirty run install ghci test test-ghci ghcid dev-deps