#!/usr/bin/perl
#
# File:   sync.pl
# Author: Mike Hamrick <mikeh@bluegecko.net>
# Updated 2013-09: Patrick Galbraith <patg@patg.net> 
#    - YAML config 
#    - loops to add directories to watch
#    - loop to add hosts for rsync
#    - switch to system to make rsync call to muliple hosts work
#
use strict;
use warnings;
use Linux::Inotify2;
use POSIX;
use File::Basename;
use File::Find;
use Proc::Daemon;
use Sys::Syslog;
use YAML qw(LoadFile);
our $settings = LoadFile('sync.yaml');

Proc::Daemon::Init;
openlog(basename($0), 'ndelay,pid', 'local6');
info("Daemon started.");

my @timedata = gmtime(time);
my $yearmon = sprintf("%d/%02d", $timedata[5] + 1900, $timedata[4] + 1);
my %workerpids;

my $rsync_prog    = '/usr/bin/rsync';
my $delete_flag   = (exists $settings->{'delete_flag'} && \
    $settings->{'delete_flag'} == 1 ) ? "--delete" : '';
my $rsync_args    = "-aPq $delete_flag";
my $terminate     = 0;
my $dw            = 0;
my $en            = 0;
my $inotify       = Linux::Inotify2->new();
my $to_watch      = IN_CLOSE_WRITE|IN_DELETE;

if (!$inotify) {
    perr("Could not create inotify object.");
    exit_program();
}

$SIG{CHLD} = \&REAPER;
$SIG{TERM} = sub { $terminate = 1; };

info("Creating watches, this could take a while...");
info("Hosts to sync to:");
for my $rsync_host (@{$settings->{'synchosts'}}) {
    info("$rsync_host")
}
my $start_time = time;
for my $syncpath (@{$settings->{'syncpaths'}}) {
    info("Adding $syncpath");
    $inotify->watch($syncpath, $to_watch);
    $dw++;
}

my $total = time - $start_time;
info("Created $dw directory watches in $total seconds.");

while () {
    my @events = $inotify->read();

    # Just in case our SIGCHLD handler missed one.
    # We don't want to leave any zombies.

    my $worker = waitpid(-1, &WNOHANG);
    if ($worker > 0) {
        foreach my $dir (keys %workerpids) {
            if ($workerpids{$dir} == $worker) {
                delete $workerpids{$dir} ;
                info("Reaped worker: $worker/$dir");
                last;
            }
        }
    }

    if ($terminate) {
        info("Shutting down on TERM signal.");
        exit_program();
    }    

    # Could be a signal that interrupted the read.
    next unless @events > 0;

    foreach my $e (@events) {
        ++$en;

        my $name = $e->fullname;
        my $mask  = mask_to_string($e->mask);
        my $cookie = $e->cookie;

        # info("Event: $en: $name, $mask, $cookie");
        handle_event($name, $e->mask, $cookie);
    }
}

perr("Program fell off the end of the world!");
exit_program();

sub handle_event {
    my $file   = shift;
    my $event  = shift;
    my $cookie = shift;
    my $dir    = dirname($file);
 
    return unless $event & IN_CLOSE_WRITE;

    # Is a process is already dealing with this directory?
    return if $workerpids{$dir};

    my $workerpid;
    if (!defined($workerpid = fork())) {
        die "Cannot fork: $!";
    }
    elsif ($workerpid == 0) {
        # WORKER
        my $ret;
        $SIG{TERM} = 'DEFAULT';

        exit 1 unless wait_for_idle_dir($dir);
        $ret = rsync_dir($dir);
        $ret ? exit 0 : exit 1;
    }
    else {
        # PARENT
        $workerpids{$dir} = $workerpid;
        info("Launched process: $workerpid to handle $dir.");
    }
}

sub rsync_dir {
    my $src_dir  = shift;
    my $dest_dir = $src_dir;

    $dest_dir =~ s/\/[^\/]+$/\//;

    for my $host (@{$settings->{'synchosts'}}) {
        my $cmdline = "$rsync_prog $rsync_args $src_dir $host:$dest_dir";
        info("rsync_dir: $cmdline");
        system($cmdline);
    }
}

sub wait_for_idle_dir {
    my $dir = shift;
    my $start = time;
    my $mtime;

    do {
        sleep 5;
        $mtime = (stat($dir))[9];
        if (!$mtime) {
            perr("wait_for_idle_dir: Can't stat $dir, $!");
            return undef;
        }
    } while (time - $mtime < 60);
    return 1;
}

sub add_watch {
    my $fname = $File::Find::name;

    return unless -d;
    next unless $fname =~ /$yearmon$/;

    ++$dw;
    $inotify->watch($fname, $to_watch);
}

sub REAPER {
    my $pid;

    $pid = waitpid(-1, &WNOHANG);

    if ($pid == -1) {
        # no worker waiting.  Ignore it.
        $SIG{CHLD} = \&REAPER;
        return;
    }
    elsif (WIFEXITED ($?)) {
        my $err;
        $? ? $err = "with error code $?." : $err = "OK.";
        info("Process $pid exited $err");
    }
    else {
        info("Process $pid died unexpectedly on signal $?.");
    }
    foreach my $dir (keys %workerpids) {
        if ($pid == $workerpids{$dir}) {
            delete $workerpids{$dir};
            last;
        }
    }
    $SIG{CHLD} = \&REAPER;
}

sub perr {
    my $message = shift;
    syslog('err', $message);
}

sub info {
    my $message = shift;
    syslog('info', $message);
}

sub mask_to_string {
    my $mask = shift;

    my @bits;
    my $ret;

    push(@bits, "IN_ACCESS")        if $mask & IN_ACCESS;
    push(@bits, "IN_MODIFY")        if $mask & IN_MODIFY;
    push(@bits, "IN_ATTRIB")        if $mask & IN_ATTRIB;
    push(@bits, "IN_CLOSE_WRITE")   if $mask & IN_CLOSE_WRITE;
    push(@bits, "IN_CLOSE_NOWRITE") if $mask & IN_CLOSE_NOWRITE;
    push(@bits, "IN_OPEN")          if $mask & IN_OPEN;
    push(@bits, "IN_MOVED_FROM")    if $mask & IN_MOVED_FROM;
    push(@bits, "IN_MOVED_TO")      if $mask & IN_MOVED_TO;
    push(@bits, "IN_CREATE")        if $mask & IN_CREATE;
    push(@bits, "IN_DELETE")        if $mask & IN_DELETE;
    push(@bits, "IN_DELETE_SELF")   if $mask & IN_DELETE_SELF;
    push(@bits, "IN_MOVE_SELF")     if $mask & IN_MOVE_SELF;
    push(@bits, "IN_ISDIR")         if $mask & IN_ISDIR;
    push(@bits, "IN_Q_OVERFLOW")    if $mask & IN_Q_OVERFLOW;
    push(@bits, "IN_UNOUNT")        if $mask & IN_UNMOUNT;
    push(@bits, "IN_IGNORED")       if $mask & IN_IGNORED;
    push(@bits, "IN_ONESHOT")       if $mask & IN_ONESHOT;

    foreach (@bits) {
        $ret .= "$_ | ";
    }
    $ret =~ s/ \| $//;
    return $ret;
}

sub kill_workers {
    my $worker;

    $SIG{CHLD} = 'DEFAULT';

    foreach my $dir (keys %workerpids) {
        my $victim = $workerpids{$dir};
        info("Killing worker pid: $victim, ($dir)"); 
        kill 15, $victim;
        wait_for_worker($victim);
    }
}

sub wait_for_worker {
    my $pid = shift;
    my $worker;

    do {
        $worker = waitpid($pid, &WNOHANG);
    } until ($worker > 0 || $worker == -1);
    info("Reaped: $pid.") if ($worker && $worker != -1);
}

sub exit_program {
    kill_workers();
    info("Exiting.");
    closelog();
    exit;
}
