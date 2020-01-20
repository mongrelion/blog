+++
title = "Scaleway Storage Solutions"
date = "2020-01-15T00:20:58+00:00"
description = ""
tags = ["scaleway", "cloud", "storage", "fio", "diskio"]
+++

I'm currently evaluating the different storage solutions that [Scaleway](https://scaleway.com)
has to offer since I want to setup a Nomad setup for running several of the services
listed on [awesome-selfhosted](https://github.com/awesome-selfhosted/awesome-selfhosted).


# Specs
The machine that I'm going to be working with has the following characteristics:
```
|--------|--------------------|
| Image  | Debian Buster      |
| Region | AMS1               |
| Cores  | 4 x86_64           |
| RAM    | 12GB               |
| Disk 1 | 25GB NVMe          |
| Disk 2 | 25GB Block Storage |
|--------|--------------------|
```

The file system on the disks is ext4.

# NVMe a.k.a. Local Storage
> Local storage volumes are located on replicate NVMe SSD disks directly connected to your instance.  
> Data is stored in a traditional File Store model, meaning your data is organized in a hierarchical structure. This means data is stored in files, which are arranged in folders and sub-directories. Data is replicated locally, and external backups can be made using the backup feature. Your server requires at least one local storage volume to boot the OS. Local storage volumes are inseparably linked to their instance. It is possible to move data of a local storage volume to another virtual cloud instance by the Snapshot feature.

# Block Storage

> Block storage volumes are ideal for performance-critical applications such as
> I/O intensive applications or transactional databases.  
> Instead of saving complete files, data is split into smaller blocks that are
> stored redundantly across multiple physical disks. This provides consistent and
> predictable performance, no matter the amount of data stored. In the case of a
> failing drive in the array, the missing blocks can easily be recovered from
> other disks in the storage device.  
> Block Storage volumes are connected to your instances using the internal network
> connection and, for mission-critical data, are physically separated from your instance.  
> Block Storage volumes can be managed on their own and be detached or attached to
> any virtual cloud instance. It is also possible to delete them independently
> from an instance.

# Figuring out which disk is which
After creating the instace through the GUI with the two disks (local and block storage)
I logged into the machine and ran `lsblk` to see that the disks were there:
```
$ lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda       8:0    0 23.3G  0 disk
vda     254:0    0 88.5G  0 disk
├─vda1  254:1    0 88.4G  0 part /
└─vda15 254:15   0  100M  0 part /boot/efi
vdb     254:16   0 23.3G  0 disk

```

Two things that I noticed are these:

1. The naming convention might gives us a clue of which one is the block storage
   device and which one is the local NVMe disk
2. The size of the extra disks is supposed to be 25GB but I see only 23.3G?

The naming convention is not something that gives me a 100% confidence that
I am dealing with one or the other type of disk. So, let's see what more information
we can get by asking some extra info from `lsblk`
```
$ lsblk -o NAME,MODEL
NAME    MODEL
sda     b_ssd
vda
├─vda1
└─vda15
vdb
```

Aha! The `sda` volume is our block storage device, so now we know what to
mount where.

# Partitioning the disks
Since we're not interested in having a fancy layout in the partition table
but rather just use the whole disk for this test, we can partition the disks
like so:
```
$ echo 'type=83' | sfdisk /dev/sda
Checking that no-one is using this disk right now ... OK

Disk /dev/sda: 23.3 GiB, 25000000000 bytes, 48828125 sectors
Disk model: b_ssd
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4194304 bytes

>>> Created a new DOS disklabel with disk identifier 0x48f48643.
/dev/sda1: Created a new partition 1 of type 'Linux' and of size 23.3 GiB.
/dev/sda2: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x48f48643

Device     Boot Start      End  Sectors  Size Id Type
/dev/sda1        8192 48828124 48819933 23.3G 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

And then the SSD:
```
$ echo 'type=83' | sfdisk /dev/vdb
Checking that no-one is using this disk right now ... OK

Disk /dev/vdb: 23.3 GiB, 25000000000 bytes, 48828125 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Created a new DOS disklabel with disk identifier 0xcadb561d.
/dev/vdb1: Created a new partition 1 of type 'Linux' and of size 23.3 GiB.
/dev/vdb2: Done.

New situation:
Disklabel type: dos
Disk identifier: 0xcadb561d

Device     Boot Start      End  Sectors  Size Id Type
/dev/vdb1        2048 48828124 48826077 23.3G 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

And with that we can move onto the next step.

# Formatting the disks
ext4 is what I have decided to go for:

```
$ mkfs.ext4 /dev/sda1
mke2fs 1.44.5 (15-Dec-2018)
Discarding device blocks: done
Creating filesystem with 6102491 4k blocks and 1525920 inodes
Filesystem UUID: fc68ee0e-9927-4841-aaf0-71e26ce1f4b6
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

```

```
$ mkfs.ext4 /dev/vdb1
mke2fs 1.44.5 (15-Dec-2018)
Creating filesystem with 6103259 4k blocks and 1525920 inodes
Filesystem UUID: 986eb554-5847-440e-bd41-d5f27362d331
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
        4096000

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done
```

# Mounting the partitions
Then we can manually mount the partitions. No need to update fstab since this
is a one-off operation and this server is going to be disposed after this
exercise:
```
$ mkdir /mnt/block-storage
$ mount /dev/sda1 /mnt/block-storage
$ mkdir /mnt/local-storage
$ mount /dev/vdb1 /mnt/local-storage
```

# The job files
The job files look like this, only changing the directory to the respective path
```
; Randomly read/write 4 files with aio at different depths
[global]
ioengine=libaio
buffered=0
rw=randrw
bs=128k
size=5G
directory=/mnt/local-storage # or /mnt/block-storage

[file1]
iodepth=4

[file2]
iodepth=8

[file3]
iodepth=16

[file4]
iodepth=32
```

I then ran them, one by one, to make sure I had all the bandwidth that I could
get from the system resources:
```
$ fio local-storage.job
```

and then the second one:
```
$ fio block-storage.job
```

# The Results
## Block Storage Results
```
file1: (g=0): rw=randrw, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=4
file2: (g=0): rw=randrw, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=8
file3: (g=0): rw=randrw, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=16
file4: (g=0): rw=randrw, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=32
fio-3.12
Starting 4 processes
file1: Laying out IO file (1 file / 5120MiB)
file2: Laying out IO file (1 file / 5120MiB)
file3: Laying out IO file (1 file / 5120MiB)
file4: Laying out IO file (1 file / 5120MiB)
Jobs: 1 (f=0): [f(1),_(3)][100.0%][r=65.1MiB/s,w=60.4MiB/s][r=520,w=483 IOPS][eta 00m:00s]
file1: (groupid=0, jobs=1): err= 0: pid=1746: Mon Jan 20 20:08:34 2020
  read: IOPS=218, BW=27.3MiB/s (28.6MB/s)(2560MiB/93850msec)
    slat (usec): min=8, max=19057, avg=96.01, stdev=397.60
    clat (usec): min=180, max=118688, avg=11375.90, stdev=10989.42
     lat (usec): min=1609, max=118862, avg=11473.29, stdev=11015.12
    clat percentiles (msec):
     |  1.00th=[    3],  5.00th=[    3], 10.00th=[    4], 20.00th=[    4],
     | 30.00th=[    5], 40.00th=[    7], 50.00th=[    8], 60.00th=[   10],
     | 70.00th=[   13], 80.00th=[   17], 90.00th=[   26], 95.00th=[   35],
     | 99.00th=[   54], 99.50th=[   62], 99.90th=[   86], 99.95th=[   99],
     | 99.99th=[  114]
   bw (  KiB/s): min= 4526, max=61894, per=21.19%, avg=23627.56, stdev=15336.22, samples=187
   iops        : min=   35, max=  483, avg=184.20, stdev=119.77, samples=187
  write: IOPS=218, BW=27.3MiB/s (28.6MB/s)(2560MiB/93850msec); 0 zone resets
    slat (usec): min=11, max=18818, avg=111.09, stdev=400.95
    clat (usec): min=7, max=91358, avg=6716.20, stdev=8761.73
     lat (usec): min=181, max=91514, avg=6828.70, stdev=8791.39
    clat percentiles (usec):
     |  1.00th=[  322],  5.00th=[  570], 10.00th=[  791], 20.00th=[ 1205],
     | 30.00th=[ 1713], 40.00th=[ 2376], 50.00th=[ 3359], 60.00th=[ 4752],
     | 70.00th=[ 6849], 80.00th=[10159], 90.00th=[16909], 95.00th=[24511],
     | 99.00th=[42206], 99.50th=[49021], 99.90th=[67634], 99.95th=[80217],
     | 99.99th=[87557]
   bw (  KiB/s): min= 5333, max=65483, per=21.16%, avg=23689.87, stdev=15450.67, samples=187
   iops        : min=   41, max=  511, avg=184.65, stdev=120.60, samples=187
  lat (usec)   : 10=0.01%, 250=0.21%, 500=1.67%, 750=2.60%, 1000=3.02%
  lat (msec)   : 2=10.14%, 4=21.04%, 10=32.30%, 20=17.78%, 50=10.32%
  lat (msec)   : 100=0.89%, 250=0.02%
  cpu          : usr=1.75%, sys=4.96%, ctx=25999, majf=0, minf=11
  IO depths    : 1=0.1%, 2=0.1%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=20478,20482,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=4
file2: (groupid=0, jobs=1): err= 0: pid=1747: Mon Jan 20 20:08:34 2020
  read: IOPS=283, BW=35.5MiB/s (37.2MB/s)(2554MiB/72017msec)
    slat (usec): min=8, max=21290, avg=83.65, stdev=438.93
    clat (usec): min=1345, max=130524, avg=16965.97, stdev=12862.17
     lat (usec): min=1912, max=130545, avg=17050.74, stdev=12877.27
    clat percentiles (msec):
     |  1.00th=[    4],  5.00th=[    5], 10.00th=[    6], 20.00th=[    8],
     | 30.00th=[    9], 40.00th=[   11], 50.00th=[   14], 60.00th=[   17],
     | 70.00th=[   20], 80.00th=[   26], 90.00th=[   35], 95.00th=[   43],
     | 99.00th=[   63], 99.50th=[   72], 99.90th=[   99], 99.95th=[  107],
     | 99.99th=[  114]
   bw (  KiB/s): min=12007, max=76291, per=28.23%, avg=31479.34, stdev=15088.92, samples=143
   iops        : min=   93, max=  596, avg=245.49, stdev=117.83, samples=143
  write: IOPS=285, BW=35.6MiB/s (37.4MB/s)(2566MiB/72017msec); 0 zone resets
    slat (usec): min=11, max=24719, avg=104.21, stdev=497.78
    clat (usec): min=13, max=102132, avg=10965.86, stdev=10553.76
     lat (usec): min=214, max=102216, avg=11071.51, stdev=10576.57
    clat percentiles (usec):
     |  1.00th=[  594],  5.00th=[ 1303], 10.00th=[ 1876], 20.00th=[ 2966],
     | 30.00th=[ 4228], 40.00th=[ 5669], 50.00th=[ 7439], 60.00th=[ 9765],
     | 70.00th=[12780], 80.00th=[17433], 90.00th=[25035], 95.00th=[32375],
     | 99.00th=[48497], 99.50th=[54789], 99.90th=[73925], 99.95th=[79168],
     | 99.99th=[89654]
   bw (  KiB/s): min= 9161, max=81589, per=28.36%, avg=31745.98, stdev=15008.23, samples=143
   iops        : min=   71, max=  637, avg=247.59, stdev=117.17, samples=143
  lat (usec)   : 20=0.01%, 100=0.01%, 250=0.04%, 500=0.32%, 750=0.48%
  lat (usec)   : 1000=0.72%
  lat (msec)   : 2=4.12%, 4=10.48%, 10=32.29%, 20=29.06%, 50=20.80%
  lat (msec)   : 100=1.64%, 250=0.05%
  cpu          : usr=1.74%, sys=5.73%, ctx=21324, majf=0, minf=12
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=100.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.1%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=20431,20529,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=8
file3: (groupid=0, jobs=1): err= 0: pid=1748: Mon Jan 20 20:08:34 2020
  read: IOPS=391, BW=48.9MiB/s (51.3MB/s)(2560MiB/52359msec)
    slat (usec): min=7, max=27789, avg=71.08, stdev=467.96
    clat (usec): min=1911, max=131146, avg=24060.16, stdev=14142.72
     lat (msec): min=2, max=131, avg=24.13, stdev=14.14
    clat percentiles (msec):
     |  1.00th=[    5],  5.00th=[    8], 10.00th=[   10], 20.00th=[   13],
     | 30.00th=[   16], 40.00th=[   18], 50.00th=[   21], 60.00th=[   25],
     | 70.00th=[   29], 80.00th=[   34], 90.00th=[   43], 95.00th=[   51],
     | 99.00th=[   72], 99.50th=[   82], 99.90th=[  100], 99.95th=[  110],
     | 99.99th=[  124]
   bw (  KiB/s): min=25037, max=81222, per=41.07%, avg=45803.36, stdev=11705.67, samples=104
   iops        : min=  195, max=  634, avg=357.47, stdev=91.35, samples=104
  write: IOPS=391, BW=48.9MiB/s (51.3MB/s)(2561MiB/52359msec); 0 zone resets
    slat (usec): min=12, max=32919, avg=94.07, stdev=600.07
    clat (usec): min=221, max=119577, avg=16659.96, stdev=12008.04
     lat (usec): min=241, max=119725, avg=16755.23, stdev=12020.42
    clat percentiles (usec):
     |  1.00th=[  1680],  5.00th=[  3326], 10.00th=[  4621], 20.00th=[  6915],
     | 30.00th=[  8848], 40.00th=[ 11207], 50.00th=[ 13698], 60.00th=[ 16450],
     | 70.00th=[ 20317], 80.00th=[ 25035], 90.00th=[ 32637], 95.00th=[ 40109],
     | 99.00th=[ 55837], 99.50th=[ 63701], 99.90th=[ 82314], 99.95th=[ 93848],
     | 99.99th=[104334]
   bw (  KiB/s): min=19928, max=77820, per=41.03%, avg=45926.09, stdev=11821.39, samples=104
   iops        : min=  155, max=  607, avg=358.46, stdev=92.28, samples=104
  lat (usec)   : 250=0.01%, 500=0.03%, 750=0.03%, 1000=0.04%
  lat (msec)   : 2=0.63%, 4=3.05%, 10=19.49%, 20=35.04%, 50=38.27%
  lat (msec)   : 100=3.36%, 250=0.05%
  cpu          : usr=2.19%, sys=6.41%, ctx=16178, majf=0, minf=12
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=100.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.1%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=20476,20484,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=16
file4: (groupid=0, jobs=1): err= 0: pid=1749: Mon Jan 20 20:08:34 2020
  read: IOPS=592, BW=74.1MiB/s (77.7MB/s)(2548MiB/34408msec)
    slat (usec): min=6, max=17677, avg=51.69, stdev=359.53
    clat (msec): min=3, max=130, avg=31.27, stdev=15.51
     lat (msec): min=3, max=130, avg=31.32, stdev=15.51
    clat percentiles (msec):
     |  1.00th=[    8],  5.00th=[   12], 10.00th=[   15], 20.00th=[   19],
     | 30.00th=[   22], 40.00th=[   26], 50.00th=[   29], 60.00th=[   33],
     | 70.00th=[   37], 80.00th=[   43], 90.00th=[   52], 95.00th=[   60],
     | 99.00th=[   84], 99.50th=[   93], 99.90th=[  117], 99.95th=[  124],
     | 99.99th=[  131]
   bw (  KiB/s): min=36644, max=129272, per=67.70%, avg=75503.60, stdev=13971.50, samples=68
   iops        : min=  286, max= 1009, avg=589.59, stdev=109.11, samples=68
  write: IOPS=597, BW=74.7MiB/s (78.4MB/s)(2572MiB/34408msec); 0 zone resets
    slat (usec): min=11, max=40188, avg=74.59, stdev=565.55
    clat (usec): min=621, max=127336, avg=22379.30, stdev=13494.42
     lat (usec): min=727, max=127360, avg=22455.37, stdev=13505.73
    clat percentiles (msec):
     |  1.00th=[    4],  5.00th=[    7], 10.00th=[    9], 20.00th=[   12],
     | 30.00th=[   14], 40.00th=[   17], 50.00th=[   20], 60.00th=[   23],
     | 70.00th=[   28], 80.00th=[   32], 90.00th=[   41], 95.00th=[   48],
     | 99.00th=[   66], 99.50th=[   78], 99.90th=[   99], 99.95th=[  124],
     | 99.99th=[  128]
   bw (  KiB/s): min=45550, max=118584, per=68.06%, avg=76184.25, stdev=14119.89, samples=68
   iops        : min=  355, max=  926, avg=594.93, stdev=110.35, samples=68
  lat (usec)   : 750=0.01%, 1000=0.01%
  lat (msec)   : 2=0.08%, 4=0.60%, 10=8.47%, 20=28.96%, 50=54.38%
  lat (msec)   : 100=7.30%, 250=0.20%
  cpu          : usr=2.36%, sys=8.04%, ctx=12393, majf=0, minf=11
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=99.9%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued rwts: total=20387,20573,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: bw=109MiB/s (114MB/s), 27.3MiB/s-74.1MiB/s (28.6MB/s-77.7MB/s), io=9.98GiB (10.7GB), run=34408-93850msec
  WRITE: bw=109MiB/s (115MB/s), 27.3MiB/s-74.7MiB/s (28.6MB/s-78.4MB/s), io=10.0GiB (10.8GB), run=34408-93850msec

Disk stats (read/write):
  sda: ios=81624/81986, merge=0/19, ticks=1678429/1136576, in_queue=2806724, util=99.41%
```

## Local Storage Results
```
file1: (g=0): rw=randrw, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=4
file2: (g=0): rw=randrw, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=8
file3: (g=0): rw=randrw, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=16
file4: (g=0): rw=randrw, bs=(R) 128KiB-128KiB, (W) 128KiB-128KiB, (T) 128KiB-128KiB, ioengine=libaio, iodepth=32
fio-3.12
Starting 4 processes
file1: Laying out IO file (1 file / 5120MiB)
file2: Laying out IO file (1 file / 5120MiB)
file3: Laying out IO file (1 file / 5120MiB)
file4: Laying out IO file (1 file / 5120MiB)
Jobs: 1 (f=1): [m(1),_(3)][100.0%][r=34.5MiB/s,w=36.0MiB/s][r=276,w=288 IOPS][eta 00m:00s]
file1: (groupid=0, jobs=1): err= 0: pid=2014: Mon Jan 20 20:34:54 2020
  read: IOPS=157, BW=19.7MiB/s (20.6MB/s)(2560MiB/130121msec)
    slat (usec): min=7, max=9464, avg=63.07, stdev=177.57
    clat (usec): min=111, max=417556, avg=12616.03, stdev=27571.41
     lat (usec): min=172, max=417682, avg=12680.32, stdev=27575.92
    clat percentiles (usec):
     |  1.00th=[   245],  5.00th=[   545], 10.00th=[   742], 20.00th=[  1090],
     | 30.00th=[  1647], 40.00th=[  2540], 50.00th=[  3294], 60.00th=[  4359],
     | 70.00th=[  5866], 80.00th=[  8586], 90.00th=[ 40109], 95.00th=[ 71828],
     | 99.00th=[130548], 99.50th=[162530], 99.90th=[235930], 99.95th=[252707],
     | 99.99th=[417334]
   bw (  KiB/s): min=  256, max=106702, per=21.74%, avg=17485.99, stdev=18531.99, samples=256
   iops        : min=    2, max=  833, avg=136.27, stdev=144.67, samples=256
  write: IOPS=157, BW=19.7MiB/s (20.6MB/s)(2560MiB/130121msec); 0 zone resets
    slat (usec): min=11, max=217132, avg=94.62, stdev=1533.82
    clat (usec): min=7, max=1802.8k, avg=12616.39, stdev=50033.52
     lat (usec): min=213, max=1802.9k, avg=12712.47, stdev=50065.26
    clat percentiles (usec):
     |  1.00th=[    293],  5.00th=[    367], 10.00th=[    429],
     | 20.00th=[    529], 30.00th=[    644], 40.00th=[    791],
     | 50.00th=[    979], 60.00th=[   1287], 70.00th=[   1876],
     | 80.00th=[   3687], 90.00th=[  33817], 95.00th=[  54789],
     | 99.00th=[ 233833], 99.50th=[ 325059], 99.90th=[ 583009],
     | 99.95th=[ 725615], 99.99th=[1233126]
   bw (  KiB/s): min=  215, max=108638, per=21.52%, avg=17372.22, stdev=18583.53, samples=258
   iops        : min=    1, max=  848, avg=135.37, stdev=145.09, samples=258
  lat (usec)   : 10=0.01%, 20=0.01%, 100=0.01%, 250=0.65%, 500=9.98%
  lat (usec)   : 750=13.23%, 1000=10.36%
  lat (msec)   : 2=18.54%, 4=16.31%, 10=14.85%, 20=2.68%, 50=6.41%
  lat (msec)   : 100=4.25%, 250=2.26%, 500=0.40%, 750=0.06%, 1000=0.01%
  cpu          : usr=0.99%, sys=2.51%, ctx=24956, majf=0, minf=13
  IO depths    : 1=0.1%, 2=0.1%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=20478,20482,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=4
file2: (groupid=0, jobs=1): err= 0: pid=2015: Mon Jan 20 20:34:54 2020
  read: IOPS=193, BW=24.1MiB/s (25.3MB/s)(2554MiB/105827msec)
    slat (usec): min=7, max=217353, avg=64.83, stdev=1527.84
    clat (usec): min=136, max=413454, avg=16951.25, stdev=31750.73
     lat (usec): min=193, max=413464, avg=17017.24, stdev=31788.02
    clat percentiles (usec):
     |  1.00th=[   310],  5.00th=[   693], 10.00th=[   988], 20.00th=[  1598],
     | 30.00th=[  2474], 40.00th=[  3294], 50.00th=[  4359], 60.00th=[  5800],
     | 70.00th=[  8094], 80.00th=[ 20841], 90.00th=[ 57410], 95.00th=[ 85459],
     | 99.00th=[145753], 99.50th=[173016], 99.90th=[250610], 99.95th=[295699],
     | 99.99th=[413139]
   bw (  KiB/s): min=  512, max=95079, per=27.00%, avg=21720.04, stdev=16798.86, samples=208
   iops        : min=    4, max=  742, avg=169.35, stdev=131.16, samples=208
  write: IOPS=193, BW=24.2MiB/s (25.4MB/s)(2566MiB/105827msec); 0 zone resets
    slat (usec): min=10, max=18024, avg=80.38, stdev=318.63
    clat (usec): min=8, max=1846.3k, avg=24203.60, stdev=69297.21
     lat (usec): min=237, max=1846.4k, avg=24285.21, stdev=69307.59
    clat percentiles (usec):
     |  1.00th=[    338],  5.00th=[    490], 10.00th=[    627],
     | 20.00th=[    889], 30.00th=[   1172], 40.00th=[   1549],
     | 50.00th=[   2073], 60.00th=[   3130], 70.00th=[   6128],
     | 80.00th=[  32900], 90.00th=[  54264], 95.00th=[ 121111],
     | 99.00th=[ 320865], 99.50th=[ 400557], 99.90th=[ 725615],
     | 99.95th=[ 851444], 99.99th=[1803551]
   bw (  KiB/s): min=  766, max=100710, per=27.12%, avg=21891.29, stdev=17047.35, samples=208
   iops        : min=    5, max=  786, avg=170.69, stdev=133.10, samples=208
  lat (usec)   : 10=0.01%, 20=0.01%, 100=0.01%, 250=0.33%, 500=3.66%
  lat (usec)   : 750=6.35%, 1000=6.79%
  lat (msec)   : 2=19.68%, 4=19.01%, 10=17.67%, 20=4.29%, 50=10.69%
  lat (msec)   : 100=6.89%, 250=3.60%, 500=0.88%, 750=0.11%, 1000=0.02%
  cpu          : usr=1.10%, sys=2.76%, ctx=19655, majf=0, minf=14
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=100.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.1%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=20431,20529,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=8
file3: (groupid=0, jobs=1): err= 0: pid=2016: Mon Jan 20 20:34:54 2020
  read: IOPS=258, BW=32.3MiB/s (33.8MB/s)(2560MiB/79330msec)
    slat (usec): min=6, max=8469, avg=49.82, stdev=128.17
    clat (usec): min=7, max=346294, avg=19730.86, stdev=31953.10
     lat (usec): min=156, max=346329, avg=19781.73, stdev=31953.82
    clat percentiles (usec):
     |  1.00th=[   297],  5.00th=[   742], 10.00th=[  1139], 20.00th=[  2180],
     | 30.00th=[  3130], 40.00th=[  4228], 50.00th=[  5604], 60.00th=[  7504],
     | 70.00th=[ 11863], 80.00th=[ 32375], 90.00th=[ 65274], 95.00th=[ 88605],
     | 99.00th=[145753], 99.50th=[162530], 99.90th=[214959], 99.95th=[231736],
     | 99.99th=[278922]
   bw (  KiB/s): min=  768, max=109824, per=37.78%, avg=30387.62, stdev=20701.42, samples=156
   iops        : min=    6, max=  858, avg=237.10, stdev=161.59, samples=156
  write: IOPS=258, BW=32.3MiB/s (33.8MB/s)(2561MiB/79330msec); 0 zone resets
    slat (usec): min=11, max=218862, avg=82.36, stdev=1550.55
    clat (usec): min=115, max=1804.4k, avg=42088.13, stdev=94290.62
     lat (usec): min=239, max=1804.5k, avg=42171.64, stdev=94303.48
    clat percentiles (usec):
     |  1.00th=[    363],  5.00th=[    562], 10.00th=[    750],
     | 20.00th=[   1254], 30.00th=[   1991], 40.00th=[   3032],
     | 50.00th=[   4752], 60.00th=[   9634], 70.00th=[  36439],
     | 80.00th=[  53216], 90.00th=[ 121111], 95.00th=[ 214959],
     | 99.00th=[ 404751], 99.50th=[ 517997], 99.90th=[ 910164],
     | 99.95th=[1417675], 99.99th=[1803551]
   bw (  KiB/s): min=  256, max=100864, per=37.70%, avg=30432.89, stdev=20671.00, samples=156
   iops        : min=    2, max=  788, avg=237.47, stdev=161.35, samples=156
  lat (usec)   : 10=0.01%, 100=0.01%, 250=0.36%, 500=2.53%, 750=4.73%
  lat (usec)   : 1000=4.30%
  lat (msec)   : 2=12.36%, 4=17.97%, 10=21.54%, 20=6.34%, 50=11.75%
  lat (msec)   : 100=10.24%, 250=5.94%, 500=1.66%, 750=0.20%, 1000=0.04%
  cpu          : usr=1.25%, sys=3.30%, ctx=16175, majf=0, minf=15
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=100.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.1%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued rwts: total=20476,20484,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=16
file4: (groupid=0, jobs=1): err= 0: pid=2017: Mon Jan 20 20:34:54 2020
  read: IOPS=405, BW=50.7MiB/s (53.1MB/s)(2548MiB/50283msec)
    slat (usec): min=5, max=217368, avg=48.06, stdev=1529.86
    clat (usec): min=43, max=321849, avg=11084.95, stdev=26594.40
     lat (usec): min=114, max=321870, avg=11133.88, stdev=26638.01
    clat percentiles (usec):
     |  1.00th=[   151],  5.00th=[   212], 10.00th=[   289], 20.00th=[   482],
     | 30.00th=[   758], 40.00th=[  1188], 50.00th=[  1958], 60.00th=[  3130],
     | 70.00th=[  4948], 80.00th=[  8848], 90.00th=[ 30540], 95.00th=[ 65274],
     | 99.00th=[139461], 99.50th=[166724], 99.90th=[214959], 99.95th=[227541],
     | 99.99th=[278922]
   bw (  KiB/s): min= 5376, max=268800, per=65.35%, avg=52563.65, stdev=45392.81, samples=99
   iops        : min=   42, max= 2100, avg=410.54, stdev=354.65, samples=99
  write: IOPS=409, BW=51.1MiB/s (53.6MB/s)(2572MiB/50283msec); 0 zone resets
    slat (usec): min=9, max=11819, avg=52.36, stdev=165.06
    clat (usec): min=65, max=1846.5k, avg=67100.68, stdev=123906.34
     lat (usec): min=158, max=1846.5k, avg=67153.97, stdev=123908.79
    clat percentiles (usec):
     |  1.00th=[    273],  5.00th=[    445], 10.00th=[    594],
     | 20.00th=[    955], 30.00th=[   1500], 40.00th=[   2638],
     | 50.00th=[   5932], 60.00th=[  24773], 70.00th=[  62653],
     | 80.00th=[ 125305], 90.00th=[ 217056], 95.00th=[ 291505],
     | 99.00th=[ 505414], 99.50th=[ 641729], 99.90th=[1417675],
     | 99.95th=[1535116], 99.99th=[1853883]
   bw (  KiB/s): min= 1792, max=266178, per=65.59%, avg=52953.13, stdev=45040.34, samples=99
   iops        : min=   14, max= 2079, avg=413.59, stdev=351.91, samples=99
  lat (usec)   : 50=0.01%, 100=0.01%, 250=4.01%, 500=9.79%, 750=8.32%
  lat (usec)   : 1000=6.38%
  lat (msec)   : 2=14.32%, 4=12.42%, 10=12.73%, 20=5.34%, 50=6.57%
  lat (msec)   : 100=6.92%, 250=9.38%, 500=3.29%, 750=0.35%, 1000=0.08%
  cpu          : usr=1.31%, sys=3.91%, ctx=13274, majf=0, minf=15
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=99.9%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued rwts: total=20387,20573,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: bw=78.6MiB/s (82.4MB/s), 19.7MiB/s-50.7MiB/s (20.6MB/s-53.1MB/s), io=9.98GiB (10.7GB), run=50283-130121msec
  WRITE: bw=78.8MiB/s (82.7MB/s), 19.7MiB/s-51.1MiB/s (20.6MB/s-53.6MB/s), io=10.0GiB (10.8GB), run=50283-130121msec

Disk stats (read/write):
  vdb: ios=81747/82051, merge=0/1, ticks=1218667/2984648, in_queue=3978312, util=91.73%
```

# Analysing the results
The block storage disk managed to achieve maximum speeds of 77.7MB/s (read) and
78.4MB/s (write).  
The local storage disk managed to achieve maximum speeds of 53.1MB/s (read) and
53.6MB/s (write).  

# Summary
I must say I am surprised: the block storage, even though it's a network storage
solution, happened to be faster than the NVMe disks.  
Appart from that, even though I have been running my cluster on Scaleway for a
few years now without a problem, there are no guarantees on them.  
Block Storage does have an SLA, promises High Availability, 3x Replica for redundancy
and the volume size (up to 10TB) is way higher (600GB) than the NVMe.
