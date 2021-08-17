test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.3 \
		bash -c 'make test-swift'

build-release-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.3 \
		bash -c 'make build-release-swift'

test-macos:
	set -o pipefail && \
	xcodebuild test \
		-scheme Gen_macOS \
		-destination platform="macOS" \
		-derivedDataPath ./.derivedData \
		| xcpretty

test-ios:
	set -o pipefail && \
	xcodebuild test \
		-scheme Gen_iOS \
		-destination platform="iOS Simulator,name=iPhone 11 Pro Max" \
		| xcpretty

test-swift:
	swift test --parallel --enable-test-discovery -v

build-release-swift:
	swift build --enable-test-discovery -c release

test-playgrounds: test-macos
	find . \
		-path '*.playground/*' \
		-name '*.swift' \
		-exec swift -F .derivedData/Build/Products/Debug/ -suppress-warnings {} +

format:
	swift format --in-place --recursive \
		./Package.swift ./Sources ./Tests

test-all: test-linux test-macos test-ios test-playgrounds
