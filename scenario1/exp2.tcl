proc exp1 {agent cbr_rate packet_size} {
    # global ns nf f0 f1
    global ns f0 f1
    set sim_time 250
    
    # Make a NS simulator 
    set ns [new Simulator]

    # # namtrace 
    # set nf [open exp1.nam w]
    # $ns namtrace-all $nf 

    # Write trace data to file to monitor
    set f0 [open exp1.tr w]
    $ns trace-all $f0

    set f1 [open exp2.tr w]

    # Define finish procedure
    proc finish {} {
        # global ns nf f0
        global ns f0 f1
        $ns flush-trace
        # close $nf 
        close $f0
        close $f1
        # exec nam exp1.nam
        exit 0
    }

    # Create 3 nodes 
    set n0 [$ns node]
    set n1 [$ns node]
    set n2 [$ns node]
    set n3 [$ns node]
    set n4 [$ns node]
    set n5 [$ns node]

    

    # Create links of the nodes: 2 access links and 1 bottleneck link
    $ns duplex-link $n0 $n2 100Mb 10ms DropTail
    $ns duplex-link $n1 $n2 100Mb 10ms DropTail
    $ns duplex-link $n2 $n3 10Mb 29ms RED
    $ns duplex-link $n3 $n4 100Mb 10ms DropTail
    $ns duplex-link $n3 $n5 100Mb 10ms DropTail

    $ns queue-limit $n2 $n3 100
    $ns queue-limit $n3 $n2 100



    # Create FTP application over TCP sender n1 
    if {$agent == "Tahoe"} {
        set tcp [new Agent/TCP]
    } else {
        set tcp [new Agent/TCP/$agent]
    }

    $ns attach-agent $n0 $tcp
    $tcp set tcpTick_ 0.001
    $tcp set window_ 100
    $tcp set fid_ 1
    $tcp set packetSize_ $packet_size
    # $tcp trace cwnd_
    $tcp trace rtt_
    $tcp trace cwnd_
    $tcp trace rto_
    $tcp attach $f1

    # Set up FTP over TCP connection 
    set ftp [new Application/FTP]
    $ftp attach-agent $tcp
    $ftp set type_ FTP

    # Connect traffic tcp to sink 
    
    set tcpsink [new Agent/TCPSink]
    $ns attach-agent $n4 $tcpsink
    $ns connect $tcp $tcpsink

    # Create CBR traffic over UDP sender n2 
    set udp [new Agent/UDP]
    $ns attach-agent $n1 $udp

    $udp set fid_ 2

    set cbr [new Application/Traffic/Exponential]
    $cbr attach-agent $udp
    $cbr set type_ Exponential
    $cbr set packetSize_ $packet_size
    $cbr set rate_ ${cbr_rate}mb
    # $cbr set random_ false

    set udpsink [new Agent/Null]
    $ns attach-agent $n5 $udpsink
    $ns connect $udp $udpsink

    $tcp set class_ 1
    $udp set class_ 2
    $ns color 1 Blue 
    $ns color 2 Red
    
    $ns at 0.0 "$cbr start"
    $ns at 0.0 "$ftp start"

    # set lossModel [new ErrorModel]
    # $lossModel set rate_ 0.01

    # $lossModel unit packet
    # $lossModel drop-target [new Agent/Null]
    # set lossyLink [$ns link $n2 $n3]
    # $lossyLink install-error $lossModel

    $ns at $sim_time "$ftp stop"
    $ns at $sim_time "$cbr stop"
    
    $ns at $sim_time "finish"

    $ns run
}

exp1 [lindex $argv 0] [lindex $argv 1] [lindex $argv 2]