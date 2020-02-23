+++
title = "Fixing data corruption problems in Ceph"
date = "2020-02-23T13:53:05+00:00"
description = ""
tags = ["cephfs", "ceph", "data corrutpion", "storage"]
+++

The first thing I want to say is: I'm really sorry that you have arrived to this
post. Most likely you are facing data corruption problems in Ceph and are looking
for an answer than can help you recover your precious data. I have some news for
you: this post might or might not help you. I'm sorry.

May the force be with you.

---

# Data corruption in Ceph: how come?
Ceph is a very resilient and consistent storage solution, if you configure it
properly, that is.

A good practice is to replicate your data among your different datacenters to
prevent data loss in case of major outages. If you lose one or more availability
zones, or even worse, a whole datacenter, your data is still available somewhere
else thanks to the miracle of replication.

The problem with these kind of distributed storage solutions is that they do not
like network latency at all. The moment you introduce high latency between the
coordination nodes, you will start perceiving odd behaviour on your cluster.
In this case, one of my customers had several block devices with corrupted data,
which was really odd because the data ingestion mechanism (plain text from multiple
sources into multiple RBDs) was very straight forward and had been running like
this for years.

While investigating a little further we found out that **about the time that the
data corruption problem arose**, the infrastructure provider had noticed **peaks
in their network latency** checks between the different datacenters.

# Fixing the problem
The following fix won't help you recover a 100% of your data but will at least
bring the affected RBDs back to operational level so that you can continue
offering your service to your customers. I hope you have backups otherwise.

Let's assume that the name of the RBD with the data corruption is called `foo`.

> The first thing you will want to do is to stop data ingestion into the problematic
  volume to avoid more damage. After that you can proceed to the steps from
  down below.

1. You need to create a snapshot of the problematic RBD:
   ```
   $ rbd snap create foo@1999-12-31
   ```
   The name of the snapshot will be `foo@1999-12-31`. I like using the date of
   the date that the snapshot was created since it makes it easy to find it
   later on.

2. You then need to "protect" the snapshot in order to be able to clone it
   later on:
   ```
   $ rbd snap protect foo@1999-12-31
   ```
3. Clone the snapshot into a new volume:
   ```
   $ rbd clone foo@1999-12-31 foo-fix
   ```
4. Map the new volume on a system where you can run the data fix. A good place is
   your ceph admin node.
   ```
   $ rbd map foo-fix
   ```
5. Assuming that the output of the previous command is `/dev/rbd0`, proceed to run
   `fsck` against the mapped volume in order to get rid of the data corruption:
   ```
   $ fsck -V -r -C /dev/rbd0
   ```
   This might take a while depending on the size and amount of data of your volume.  
   A little more information about `fsck` and what we're doing with it:  
   **fsck** - check and repair a Linux filesystem.
   - `-V `  Produce verbose output, including all filesystem-specific
            commands that are executed.  
   - `-r`   Report certain statistics for each fsck when it completes.
            These statistics include the exit status, the maximum run set
            size (in kilobytes), the elapsed all-clock time and the user
            and system CPU time used by the fsck run.  For example:  
            /dev/sda1: status 0, rss 92828, real 4.002804, user 2.677592,
            sys 0.86186  
   - `-C`   Display completion/progress bars for those filesystem checkers
            (currently only for ext[234]) which support them.  fsck will
            manage the filesystem checkers so that only one of them will
            display a progress bar at a time.

That's pretty much it. The strategy on how to bring the newly fixed volume into
production is up to you. I'd recommend you decommission the old volume, bring
the new one into production while keeping the old one around for a few days with
some monitoring in place until you are a 100% sure that the issues are gone and
that your service is now within the SLA.
