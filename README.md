# RaspberryPi Headless Builder

This is a simple, opinionated script for provisioning a Raspbian image up front.  Designed for IOT/headless lite installations it:

* Reduces gpu memory
* Sets up a default wifi connection
* Sets the hostname
* Enables SSH
* Adds SSH keys from a github account
* Disables password auth

The resulting `.img` file can then be burned to an SD card and the machine can be brought up and further provisioning can be done.

The script expects an existing raspian image to exist in the `bases` directory.  Specify which base to use with `RHB_BASE`.

The script expects the following environment variables:

| `RHB_BASE`       | Filename to use from `bases` directory |
| `RHB_GITHUBUSER` | Github user name to grab SSH keys for  |
| `RHB_HOSTNAME`   | Hostname to give machine               |
| `RHB_SSID`       | SSID to connect to                     |
| `RHB_PSK`        | Pre-shared key for WiFi connection     |

These can either be specified traditionally, or added to a file named `build_params`. See `build_params.sample`

The resulting ready-to-burn image is written to `out/build.img`
