# files
.packages: pubspec.yaml
	dart pub get

# hooks
hook: get
 dart pub run hanzo -i pre_commit

unhook: get
 dart pub run hanzo -r all

# targets
get: .packages

get-clean:
	rm -rf .dart_tool
	rm -rf .packages
	$(MAKE) get

upgrade: get
	dart pub upgrade

build: get
	dart pub run build_runner build

build-clean: upgrade
	dart pub run build_runner build --delete-conflicting-outputs
	
watch: get
	dart pub run build_runner watch
	
watch-clean: upgrade
	dart pub run build_runner watch --delete-conflicting-outputs

analyze: get
	dart analyze --fatal-infos

test: get
	dart test

test-coverage: get
	@rm -rf coverage
	dart test --coverage=coverage
	dart pub run coverage:format_coverage --lcov -i coverage -o coverage/lcov.info --packages .packages --report-on lib -c
	lcov --remove coverage/lcov.info -o coverage/lcov.info \
		'**/*.g.dart' \
		'**/*.freezed.dart' \
		'**/models/*.dart'

coverage: test-coverage
	genhtml -o coverage/html coverage/lcov.info

coverage-open: coverage
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

.PHONY: build test coverage doc
