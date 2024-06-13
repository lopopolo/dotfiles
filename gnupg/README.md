# GnuPG Config

## macOS

## Install

```shell
brew install gnupg pinentry-mac
```

### GPG Agent Config

```shell
# Make the directory
mkdir -p ~/.gnupg

# Tells GPG which pinentry program to use
echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf
```

### Root Config

```shell
# This tells gpg to use the gpg-agent
echo 'use-agent' > ~/.gnupg/gpg.conf
```

## Import

1. Import private key for developer machine and mark as ultimately trusted:
   ```shell
   pbpaste | gnupg --import
   echo "B54B7B3FA506699945AF2E6E46047D739B6AE0B1:6" | gpg --import-ownertrust
   ```
2. Import other @lopopolo public keys and mark as ultimately trusted:
   ```shell
   pbpaste | gnupg --import
   echo "BFD9A9916E5A87A9B3550C11717CDD6DC84E7D45:6" | gpg --import-ownertrust
   ```
3. Import GitHub webflow signing key:
   ```shell
   wget -O- https://github.com/web-flow.gpg | gpg --import
   ```
