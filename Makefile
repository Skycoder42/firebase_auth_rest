# files
.packages: pubspec.yaml
	@rm pubspec.lock
	dart pub get

lib/models/%.freezed.dart: .build-runner-trigger .packages

lib/models/%.g.dart: lib/models/%.freezed.dart

.build-runner-trigger: $(wildcard lib/models/*.freezed.dart)
	touch .build-runner-trigger
	echo pub run build_runner build --delete-conflicting-outputs

generate2: $(wildcard lib/models/*.freezed.dart) $(wildcard lib/models/*.g.dart) .build-runner-trigger

# targets
.PHONY: get build generate watch test coverage doc publish

get: .packages

build: .build-runner-completed

generate: get
	dart pub run build_runner build --delete-conflicting-outputs
	
watch: get
	dart pub run build_runner watch --delete-conflicting-outputs

test: get
	dart test

coverage: get
	@rm -rf coverage
	dart test --coverage=coverage
	dart pub run coverage:format_coverage --lcov -i coverage -o coverage/lcov.info --packages .packages --report-on lib -c
	lcov --remove coverage/lcov.info -o coverage/lcov.info \
		'**/*.g.dart' \
		'**/*.freezed.dart' \
		'**/models/*.dart'
	genhtml -o coverage/html coverage/lcov.info
	xdg-open coverage/html/index.html || start coverage/html/index.html

doc: get
	@rm -rf doc
	dartdoc --show-progress 
	xdg-open doc/api/index.html || start doc/api/index.html

publish: get
	rm lib/src/.gitignore
	dart pub publish
	echo '# Generated dart files' > lib/src/.gitignore
	echo '*.freezed.dart' >> lib/src/.gitignore
	echo '*.g.dart' >> lib/src/.gitignore
