# sources
LIB_FILES = $(shell find ./lib -type f -iname "*.dart")
SRC_FILES = $(shell find ./lib/src -type f -iname "*.dart")
UNIT_TEST_FILES = $(shell find ./test/unit -type f -iname "*.dart")
INTEGRATION_TEST_FILES = $(shell find ./test/integration -type f -iname "*.dart")
TEST_FILES = $(UNIT_TEST_FILES) $(INTEGRATION_TEST_FILES)

#get 
.packages: pubspec.yaml
	dart pub get

get: .packages

get-clean:
	rm -rf .dart_tool
	rm -rf .packages
	$(MAKE) get

upgrade: .packages
	dart pub upgrade

# hooks
hook: .packages unhook
	echo '#!/bin/sh' > .git/hooks/pre-commit
	echo 'exec dart pub run --no-sound-null-safety dart_pre_commit -p -oany -n --ansi' >> .git/hooks/pre-commit
	chmod a+x .git/hooks/pre-commit

unhook:
	rm -f .git/hooks/pre-commit

# build
build: .packages
	dart run build_runner build

build-clean: upgrade
	dart run build_runner build --delete-conflicting-outputs
	
watch: .packages
	dart run build_runner watch
	
watch-clean: upgrade
	dart run build_runner watch --delete-conflicting-outputs

# analyze
analyze: .packages
	dart analyze --fatal-infos

# test
unit-tests: get
	dart --no-sound-null-safety --null-assertions test test/unit

integration-tests: get
	@test -n "$(FIREBASE_API_KEY)"
	dart --no-sound-null-safety --null-assertions test test/integration

test: get
	$(MAKE) unit-tests
	$(MAKE) integration-tests

# coverage
coverage/.generated: .packages $(SRC_FILES) $(UNIT_TEST_FILES)
	@rm -rf coverage
	dart --no-sound-null-safety --null-assertions test --coverage=coverage test/unit
	touch coverage/.generated

coverage/lcov.info: coverage/.generated
	dart run coverage:format_coverage --lcov --check-ignore \
		--in coverage \
		--out coverage/lcov.info \
		--packages .packages \
		--report-on lib

coverage/lcov_cleaned.info: coverage/lcov.info
	lcov --remove coverage/lcov.info -output-file coverage/lcov_cleaned.info \
		'**/*.g.dart' \
		'**/*.freezed.dart' \
		'**/models/*.dart'

coverage/html/index.html: coverage/lcov_cleaned.info
	genhtml --no-function-coverage -o coverage/html coverage/lcov_cleaned.info

coverage: coverage/html/index.html

unit-test-coverage: coverage/lcov.info

coverage-open: coverage/html/index.html
	xdg-open coverage/html/index.html || start coverage/html/index.html

#doc 
doc/api/index.html: .packages $(LIB_FILES)
	@rm -rf doc
	dartdoc --show-progress

doc: doc/api/index.html

doc-open: doc
	xdg-open doc/api/index.html || start doc/api/index.html

# publish
pre-publish:
	rm lib/src/.gitignore

post-publish:
	echo '# Generated dart files' > lib/src/.gitignore
	echo '*.freezed.dart' >> lib/src/.gitignore
	echo '*.g.dart' >> lib/src/.gitignore

publish-dry: .packages
	$(MAKE) pre-publish
	dart pub publish --dry-run
	$(MAKE) post-publish

publish: .packages
	$(MAKE) pre-publish
	dart pub publish --force
	$(MAKE) post-publish

# verify
verify:
	$(MAKE) build-clean
	$(MAKE) analyze
	$(MAKE) unit-test-coverage
	$(MAKE) integration-tests
	$(MAKE) coverage-open
	$(MAKE) doc-open
	$(MAKE) publish-dry



.PHONY: build test coverage doc
