How to update to newer OpenSSL version, build, and publish a release.

1. **Clone this repository.**

   ```shell
   git clone https://github.com/cossacklabs/openssl-apple
   ```

   Make sure you're on the `cossacklabs` branch.

2. **Update OpenSSL version.**

   The version number is in the [`Makefile`](Makefile).

   Also update tarball checksums in [`build-libssl.sh`](build-libssl.sh).

3. **Update platform configuration.**

   Things like minimum OS SDK versions, architectures, etc.
   You can find all this in the [`Makefile`](Makefile).

4. **Build OpenSSL.**

   ```shell
   make
   ```

   This can take a while.
   Not only it builds the library, this also packages it,
   and updates the project specs.

5. **Commit, tag, push the release.**

   ```shell
   git add carthage
   git commit -S -e -m "OpenSSL 1.1.1g"
   git tag -s -e -m "OpenSSL 1.1.1g" v1.1.107
   git push origin cossacklabs # Push the branch
   git push origin v1.1.107    # Push the tag
   ```

   Make will remind you how to do this.
   (Use the correct versions there.)
   Take care to make signed commits and tags, this is important for vanity.

   Congratulations!
   You have just published a broken Carthage package.

6. **Publish GitHub release with binary framework files.**

   Go to GitHub release page for the tag:

   https://github.com/cossacklabs/openssl-apple/releases/tag/v1.1.107

   press **Edit tag** and upload `*.zip` packages from `output` directory.

   Also, describe the release, press the **Publish release** when done.

   Congratulations!
   You should have fixed the Carthage package with this.

7. **Publish podspec.**

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
