xcodeproj:
	PF_DEVELOP=1 swift run xcodegen

test-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.2.3 \
		bash -c 'swift test --parallel --enable-pubgrub-resolver --enable-test-discovery -v'

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
		-destination platform="iOS Simulator,name=iPhone XR,OS=12.2" \
		| xcpretty

test-swift:
	swift test -v

test-playgrounds: test-macos
	find . \
		-path '*.playground/*' \
		-name '*.swift' \
		-exec swift -F .derivedData/Build/Products/Debug/ -suppress-warnings {} +

format:
	swift format --in-place --recursive \
		./Package.swift ./Sources ./Tests

test-all: test-linux test-macos test-ios test-playgrounds
