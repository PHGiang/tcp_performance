proc exp1 {agent no_sources packet_size} {
    # global ns nf f0 f1
    global ns f0 f1
    set sim_time 250
    set start_time 0
    
    # Make a NS simulator 
    set ns [new Simulator]

    # namtrace 
    set nf [open exp1.nam w]
    $ns namtrace-all $nf 

    # Write trace data to file to monitor
    set f0 [open exp1.tr w]
    $ns trace-all $f0

    set f1 [open exp2.tr w]

    # Define finish procedure
    proc finish {} {
        # global ns nf f0 f1
        global ns f0 f1
        $ns flush-trace
        # close $nf 
        close $f0
        close $f1
        # exec nam exp1.nam
        exit 0
    }


    set S [$ns node]
    set D [$ns node]
    $ns duplex-link $S $D 10Mb 29ms RED 
    $ns queue-limit $S $D 100
    $ns queue-limit $D $S 100

    # Random number generator
    set rng [new RNG]
    $rng seed 0
    set size [new RandomVariable/Uniform]
    # $size set avg_ $no_sources
    $size use-rng $rng
    for {set i 0} {$i<$no_sources} {set i [expr $i+1]} {
        set s($i) [$ns node]
        set d($i) [$ns node]
        $ns duplex-link $s($i) $S 100Mb 1ms DropTail
        $ns duplex-link $D $d($i) 100Mb 1ms DropTail

        # Create FTP application over TCP sender n1 
        if {$agent == "Tahoe"} {
            set tcp($i) [new Agent/TCP]
        } else {
            set tcp($i) [new Agent/TCP/$agent]
        }
        $ns attach-agent $s($i) $tcp($i)
        $tcp($i) set tcpTick_ 0.001
        $tcp($i) set window_ 100
        $tcp($i) set fid_ $i
        $tcp($i) set packetSize_ $packet_size

        # $tcp trace cwnd_
        $tcp($i) trace rtt_
        $tcp($i) trace cwnd_
        $tcp($i) trace rto_
        $tcp($i) attach $f1


        # Connect traffic tcp to sink 
    
        set tcpsink($i) [new Agent/TCPSink]
        $ns attach-agent $d($i) $tcpsink($i)
        $ns connect $tcp($i) $tcpsink($i)

        # Set up FTP over TCP connection 
        set ftp($i) [new Application/FTP]
        $ftp($i) attach-agent $tcp($i)
        $ftp($i) set type_ FTP
        set stime [expr 1.0*[$size value]]
        $ns at $stime "$ftp($i) start"
    }
        
    $ns at $sim_time "finish"

    $ns run
}

exp1 [lindex $argv 0] [lindex $argv 1] [lindex $argv 2]