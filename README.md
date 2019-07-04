## Usage

Fork, edit, use like this:

`wget https://raw.githubusercontent.com/%username%/iarq/wtfiamdoing/install.sh | hn=hostname_here bash -xe`

## WAT?

This is a list of commands that you intended to run to get your arch installed from an arch livecd shell https://www.archlinux.org/download/
All major modifications (like complicated partitioning) should go to a separate branch.

## TODO

* Put `mitigations=off` in /etc/default/somethingsomething
* Enable swap and zswap?
* Add user creation `[ -z "$u" ] && chroot useradd $u`

## Licence

MIT
