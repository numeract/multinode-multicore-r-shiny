# multinode-multicore-r-shiny
# explore makeCluster_ec2 - step by step


# Part 1 - setup
library(parallel)


calc_pi <- function(max_level = NULL, sample_size = 1e+6) {
    # calculates pi using simulation
    # max_level not used in this function, included for compatibility
    # increase sample_size if you have enough memory
    # otherwise, call it many times and average the results
    # returns one value
    
    r <- 2
    x <- runif(sample_size, min = -r, max = +r)
    y <- runif(sample_size, min = -r, max = +r)
    c <- complex(real = x, imaginary = y)
    count_inside <- sum( Mod(c) <= r )
    return( 4 * count_inside / sample_size ) 
}


#variables - find out exact settings for your local computer

# IP of this machine (master)
IP_local <- 'x.x.x.x'

# IP of Ubuntu VM (slave)
IP_UbuntuVM <- 'x.x.x.x'

# username to connect to Ubuntu VM
user_UbuntuVM <- 'ubuntu'

# on Windows: full path to plink and full path to private key .ppk (notice the quotes)
# on Ubuntu: 'ssh'
# rshcmd <- '"C:/###/plink.exe" -i "c:/###/###.ppk"'
rshcmd <- 'ssh'


# Part 2 - local computer, simple test
print( calc_pi() )
print(mean( sapply(1:100, FUN = calc_pi) ))



# Part 3 - local computer, 2 node cluster
cl <- makeCluster(spec = 2)

print(mean(unlist( clusterApplyLB(cl = cl, x = 1:100, fun = calc_pi) )))

stopCluster(cl)  # stop the cluster to avoid zombies



# Part 4 - slave UbuntuVM manual mode, 1 vCPU
cl <- makeCluster(
    spec = c(IP_UbuntuVM),
    master = IP_local, 
    port = 11011,
    user = 'ubuntu',
    homogeneous = TRUE,
    manual = TRUE, outfile = "")

print(mean(unlist( clusterApplyLB(cl = cl, x = 1:100, fun = calc_pi) )))

stopCluster(cl)



# Part 5a, 5b - skip



# Part 6 - UbuntuVM automode mode, 1 vCPU, success
cl <- makeCluster(
    spec = c(IP_UbuntuVM),
    master = IP_local, 
    port = 11011,
    user = 'ubuntu',
    rshcmd = rshcmd,    # must be ssh
    homogeneous = TRUE,
    manual = FALSE, outfile = "")

print(mean(unlist( clusterApplyLB(cl = cl, x = 1:100, fun = calc_pi) )))

stopCluster(cl)



# Part 7 - local + UbuntuVM, 4 vCPU
cl <- makeCluster(
    spec = c( 'localhost', 'localhost', IP_UbuntuVM, IP_UbuntuVM),
    master = IP_local, 
    port = 11011,
    user = 'ubuntu',
    rshcmd = rshcmd,    # must be ssh
    homogeneous = TRUE,
    manual = FALSE, outfile = "")

print(mean(unlist( clusterApplyLB(cl = cl, x = 1:100, fun = calc_pi) )))

stopCluster(cl)
