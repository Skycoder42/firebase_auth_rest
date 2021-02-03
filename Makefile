# files
.packages: pubspec.yaml
	dart pub get

# hooks
hook: get unhook
	echo '#!/bin/sh' > .git/hooks/pre-commit
	echo 'exec dart pub run --no-sound-null-safety dart_pre_commit -p -oany -n --ansi' >> .git/hooks/pre-commit
	chmod a+x .git/hooks/pre-commit

unhook:
	rm -f .git/hooks/pre-commit

# targets
get: .packages

get-clean:
	rm -rf .dart_tool
	rm -rf .packages
	$(MAKE) get

upgrade: get
	dart pub upgrade

build: get
	dart run build_runner build

build-clean: upgrade
	dart run build_runner build --delete-conflicting-outputs
	
watch: get
	dart run build_runner watch
	
watch-clean: upgrade
	dart run build_runner watch --delete-conflicting-outputs

analyze: get
	dart analyze --fatal-infos

test: get
	dart --no-sound-null-safety test

coverage/.generated: $(wildcard test/*.dart) $(wildcard src/*.dart) $(wildcard bin/*.dart)
	@rm -rf coverage
	dart --no-sound-null-safety test --coverage=coverage
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
	genhtml -o coverage/html coverage/lcov_cleaned.info

coverage: coverage/html/index.html

test-coverage: coverage/lcov.info

coverage-open: coverage/html/index.html
	xdg-open coverage/html/index.html || start coverage/html/index.html

doc: get
	@rm -rf doc
	dartdoc --show-progress

doc-open: doc
	xdg-open doc/api/index.html || start doc/api/index.html

pre-publish:
	rm lib/src/.gitignore

post-publish:
	echo '# Generated dart files' > lib/src/.gitignore
	echo '*.freezed.dart' >> lib/src/.gitignore
	echo '*.g.dart' >> lib/src/.gitignore

publish-dry: get
	$(MAKE) pre-publish
	dart pub publish --dry-run
	$(MAKE) post-publish

publish: get
	$(MAKE) pre-publish
	dart pub publish --force
	$(MAKE) post-publish

verify: get
	$(MAKE) build-clean
	$(MAKE) analyze
	$(MAKE) coverage-open
	$(MAKE) doc-open
	$(MAKE) publish-dry

.PHONY: build test coverage doc
