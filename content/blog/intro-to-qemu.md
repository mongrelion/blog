+++
title = "Introduction to Qemu"
date = "2020-02-03T00:23:05+00:00"
description = ""
tags = ["qemu", "virtualization"]
+++

Through my whole career and also during my studies I have always resorted to
VirtualBox for my personal virtualization needs and VMWare for my customers'.

Qemu has been under my peripheral vision for a few years now but since I was always
happy with VirtualBox I hadn't really had a need to look somewhere else.

So, I'm still happy with VirtualBox but I now want to give Qemu a try, so here
are my findings.

# Getting Started
It seems like the fastest way to get started with qemu is from the command line,
even though there are plenty of options out there to get a GUI running; however,
I stopped being afraid of the terminal years ago so let's just give this a go.

# Disk
We first are going to need a disk image, somewhere to store our data once the VM
is up & running unless, of course, we only want to run a "live" distro.

The command for creating a new disk image with qemu is the following:
```
$ qemu-img create [--object objectdef] [-q] [-f fmt] [-b backing_file] [-F backing_fmt] [-u] [-o options] filename [size]
```

Adapting it to our needs, we end up with this:
```
$ qemu-img create -f raw the-image.img 20G
```

Let's take a look at the arguments:

- The `-f raw` specifies the format that we want to give to this image. I have chosen
  `raw` because it gives hte most performance and it suits my needs.
  [Here](https://en.wikibooks.org/wiki/QEMU/Images#Image_types) in the documentation you
  can take a look at the rest of the image formats available for qemu
- `the-image.img` is simply the filename of our image
- `20G` is the size of the image

# Booting
I have downloaded an ISO with ArchLinux in it but please feel free to use your
favorite distro for this example.

```
$ qemu-system-x86_64 -m 1G -drive file=the-image.img,format=raw -boot d -cdrom archlinux.iso
```

Looking into the argumets passed to qemu, we see that
- We are assigning 1GB of RAM to the VM via the parameter `-m 1G`
- We are specifying the base disk via the `-drive` parameter. The documentation
  shows in their example to simply pass the `-hda` parameter followed by the image
  name but in my case resulted in a warning saying the following:
  ```
  WARNING: Image format was not specified for 'winxp.img' and probing guessed raw.
           Automatically detecting the format is dangerous for raw images, write operations on block 0 will be restricted.
           Specify the 'raw' format explicitly to remove the restrictions.
  ```
  And it's better to tackle warnings head-on.
- The `-boot d` option tells the virual machine to boot from the cdrom
  (floppy (a), hard disk (c), CD-ROM (d), network (n))
- Finally, the `-cdrom` option tricks the virtual machine into thinking that
  `archlinux.iso` is the cdrom mounted in the system


That would be the end of it, actually. The networking part we can skip and qemu
will by default assing a vNIC to the machine, bridged to the host and give it
access to Internet, so you can get cracking right away.

# Final thoughts
Being used to the clicky workflow of VirtualBox, using qemu feels just a bit daunting
in the beginning but it's only from all the steps that one could think of when
creating a virtual machine: assing CPUs, RAM, Networking, Storage, etc. and having
to do all that from the console is, well, a bit of a pain.
But all the pain is gone once you script the manual steps away.

Happy hacking!
