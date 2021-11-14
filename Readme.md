### change C++ code then recompile
```
cd ./ns-2.35
make clean
make 
sudo make install
```
Timeout reference: 

[1] https://www.catchpoint.com/blog/tcp-rtt

TCP simulation in NS2

[2] https://github.com/Riteshgpt11/TCP-Simulation-in-NS-2
[3] https://www.isi.edu/nsnam/ns/ns-man.html

the starting time of TCP source are evenly distributed in the interval 0s - 1s
RandomVariable/Uniform set min_ 0.0
RandomVariable/Uniform set max_ 1.0
