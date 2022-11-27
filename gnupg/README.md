# GnuPG Config

## macOS

### Root Config

In `~/.gnupg/gpg.conf`:

```
# Uncomment within config (or add this line)
# This tells gpg to use the gpg-agent
use-agent
```

This configuration requires the `gpg` binary installed via Homebrew. For
example:

```console
$ brew info gpg
==> gnupg: stable 2.3.8 (bottled)
GNU Pretty Good Privacy (PGP) package
https://gnupg.org/
/usr/local/Cellar/gnupg/2.3.8 (151 files, 13.7MB) *
  Poured from bottle on 2022-10-20 at 23:50:08
From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/gnupg.rb
License: GPL-3.0-or-later
==> Dependencies
Build: pkg-config ✔
Required: gettext ✔, gnutls ✔, libassuan ✔, libgcrypt ✔, libgpg-error ✔, libksba ✔, libusb ✔, npth ✔, pinentry ✔
==> Analytics
install: 98,430 (30 days), 288,289 (90 days), 1,069,472 (365 days)
install-on-request: 94,099 (30 days), 273,484 (90 days), 1,010,921 (365 days)
build-error: 10 (30 days)
```

### GPG Agent Config

In `~/.gnupg/gpg-agent.conf`:

```
# Connects gpg-agent to the OSX keychain via the brew-installed
# pinentry program from GPGtools. This is the OSX 'magic sauce',
# allowing the gpg key's passphrase to be stored in the login
# keychain, enabling automatic key signing.
pinentry-program /usr/local/bin/pinentry-mac
```

This configuration requires the `pinentry-mac` binary installed via Homebrew.
For example:

```console
$ brew info pinentry-mac
==> pinentry-mac: stable 1.1.1.1 (bottled), HEAD
Pinentry for GPG on Mac
https://github.com/GPGTools/pinentry
/usr/local/Cellar/pinentry-mac/1.1.1.1 (16 files, 460.2KB) *
  Poured from bottle on 2021-12-15 at 22:59:17
From: https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/pinentry-mac.rb
License: GPL-2.0-or-later and GPL-3.0-or-later
==> Dependencies
Build: autoconf ✔, automake ✔, libtool ✔
Required: gettext ✔, libassuan ✔
==> Requirements
Build: Xcode ✔
Required: macOS ✔
==> Options
--HEAD
        Install HEAD version
==> Caveats
You can now set this as your pinentry program like

~/.gnupg/gpg-agent.conf
    pinentry-program /usr/local/bin/pinentry-mac
==> Analytics
install: 5,527 (30 days), 17,274 (90 days), 68,415 (365 days)
install-on-request: 5,438 (30 days), 16,880 (90 days), 66,645 (365 days)
build-error: 1 (30 days)
```
