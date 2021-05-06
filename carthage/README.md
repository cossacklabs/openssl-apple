Carthage binary frameworks
==========================

Here you can find JSON files with [binary project specifications][1] for Carthage.
Update these files with new versions when doing the release.

[1]: https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#binary-project-specification

Note that Carthage **requires** semver-compatible versions.
That is, the version must have three components.
OpenSSL uses a peculiar versioning scheme which has four components
where patch version is indicated by a letter.
OpenSSL versions are translated to Carthage versions by renumbering like this:

| OpenSSL version | Carthage version |
| --------------- | ---------------- |
| 1.0.2           | 1.0.200          |
| 1.0.2a          | 1.0.201          |
| 1.0.2u          | 1.0.221          |
| 1.1.1           | 1.1.100          |
| 1.1.1a          | 1.1.101          |
| 1.1.1g          | 1.1.107          |
| 1.1.1h          | 1.1.10801        |
| 1.1.1h          | 1.1.10802        | (no changes in OpenSSL, added arm64)
| 1.1.1h          | 1.1.10803        | (no changes in OpenSSL, XCF support)
| 1.1.1k          | 1.1.11101        | (XCF-only)
