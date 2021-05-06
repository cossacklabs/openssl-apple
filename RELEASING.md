How to update to newer OpenSSL version, build, and publish a release.

1. **Clone this repository.**

   ```shell
   git clone https://github.com/cossacklabs/openssl-apple
   ```

   Make sure you're on the `cossacklabs` branch.

2. **Update OpenSSL version.**

   The version number is in the [`Makefile`](Makefile).

   Increment `PACKAGE_VERSION` if you are repackaging the same OpenSSL version.
   Otherwise, update `VERSION` to OpenSSL version and reset `PACKAGE_VERSION` to `1`.

   Also update tarball checksums in [`build-libssl.sh`](build-libssl.sh).

3. **Update platform configuration.**

   Things like minimum OS SDK versions, architectures, etc.
   You can find all this in the [`Makefile`](Makefile).

4. **Build OpenSSL.**

   To build from scratch - remove output folder.

   ```shell
   make
   ```

   This can take a while.
   Not only it builds the library, this also packages it,
   and updates the project specs.

5. **Update SPM package settings**

	 Update [`Package.swift`](Package.swift) file with the new URL of the binary framework and its checksum:

   ```swift
   .binaryTarget(name: "openssl",
              // update version in URL path
              url:"https://github.com/cossacklabs/openssl-apple/releases/download/1.1.10701/openssl-static-xcframework.zip",
              // Run from package directory:
              // swift package compute-checksum output/openssl-static-xcframework.zip
              checksum: "77b9a36297a2cade7bb6db5282570740a2af7b1e5083f126f46ca2671b14d73e"),
   ```

6. **Commit, tag, push the release.**

   Tag should be in a semver format.

   ```shell
   git add carthage
   git add Package.swift
   git commit -S -e -m "OpenSSL 1.1.1g"
   git tag -s -e -m "OpenSSL 1.1.1g" 1.1.10701
   git push origin cossacklabs # Push the branch
   git push origin 1.1.10701  # Push the tag
   ```

   Make will remind you how to do this.
   (Use the correct versions there.)
   Take care to make signed commits and tags, this is important for vanity.

   Congratulations!
   You have just published broken Carthage and SPM packages :)

7. **Publish GitHub release with binary framework files.**

   Go to GitHub release page for the tag:

   https://github.com/cossacklabs/openssl-apple/releases/tag/1.1.107

   press **Edit tag** and upload `*.zip` packages from `output` directory.

   Also, describe the release, press the **Publish release** when done.

   Congratulations!
   You should have fixed the Carthage and SPM packages with this.

8. **Publish podspec.**

   ```shell
   pod trunk push cocoapods/CLOpenSSL.podspec
   ```

   This lints the podspec before publishing it.
   If it does not lint then curse at CocoaPods and scrub the release.

   Congratulations!
   You have published a CocoaPods package.

Actually, you have published all of the OpenSSL.
Now is the time to go check if it *actually* works.
You can use [Themis](https://github.com/cossacklabs/themis) for that.
