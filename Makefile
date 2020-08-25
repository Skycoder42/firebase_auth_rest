# files
.packages: pubspec.yaml pubspec.lock
	pub get

lib/models/%.freezed.dart: .build-runner-trigger .packages

lib/models/%.g.dart: lib/models/%.freezed.dart

.build-runner-trigger: $(wildcard lib/models/*.freezed.dart)
	touch .build-runner-trigger
	echo pub run build_runner build --delete-conflicting-outputs

generate2: $(wildcard lib/models/*.freezed.dart) $(wildcard lib/models/*.g.dart) .build-runner-trigger

# targets
get: .packages

build: .build-runner-completed

generate: get
	pub run build_runner build --delete-conflicting-outputs
	
watch:
	pub run build_runner watch --delete-conflicting-outputs

tests:
	pub run test

publish:
	rm lib/src/.gitignore
	pub publish
	echo '# Generated dart files' > lib/src/.gitignore
	echo '*.freezed.dart'
	echo '*.g.dart'
